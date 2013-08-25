//
//  CarPanelViewController.m
//  NavierIOS
//
//  Created by Coming on 13/6/29.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "CarPanel1ViewController.h"
#import <NaviUtil/NaviUtil.h>
#import "ClockView.h"
#import "SystemStatusView.h"

#define FILE_DEBUG TRUE
#include <NaviUtil/Log.h>

@interface CarPanel1ViewController ()
{
    CarPanel1UIView *_carPanel1;
    NSTimer *_redrawTimer;
    int _redrawInterval;
//    NSTimer *_clockTimer;
//    NSDateFormatter *_clockTimerFormater;
    NSMutableArray *_courseLabelArray;
    
//    BatteryLifeView *_batteryLifeView;
    ClockView *_clockView;
    SystemStatusView *_systemStatusView;
    
    
    
    float _courseAngleToPixelOffset;
    CGPoint _courseLabelOrigins[8];
    float _courseCenterNOffset;
    BOOL _isShowCarPanelMenu;
    UIView *_carPanelMenu;
    UIButton *_carPanelMenuLogoButton;
    UIButton *_carPanelMenuHudButton;
    UIButton *_carPanelMenuSpeedMphButton;
    UIButton *_carPanelMenuSpeedKmhButton;
    
    UILabel *_carPanelMenuHudLabel;
    UILabel *_carPanelMenuCourseLabel;
    UILabel *_carPanelMenuUnitLabel;
  
    UISwitch *_carPanelMenuHudSwitch;
    UISwitch *_carPanelMenuCourseSwitch;
    
    NSMutableArray *_colorButtons;
    CGSize _colorButtonUnselectedSize;
    CGSize _colorButtonSelectedSize;
}
@end

@implementation CarPanel1ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

    }
    return self;
}

- (void) initSelf
{
    _redrawInterval = 0.5;
    _redrawTimer    = nil;
    _colorButtons   = [[NSMutableArray alloc] initWithCapacity:5];

    [self addUIComponents];
    
    self.isHud      = FALSE;
    self.isCourse   = FALSE;
    self.speed      = 0;
    

    [self addCarPanelMenu];
    [self updateColorFromConfig];
    
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)viewDidLoad
{
    [self initSelf];
    
    [super viewDidLoad];
  
    
    [_speedLabel        setFont:[UIFont fontWithName:@"JasmineUPC" size:250]];
    [_speedUnitLabel    setFont:[UIFont fontWithName:@"JasmineUPC" size:35]];
    
    _courseLabelArray = [[NSMutableArray alloc] initWithCapacity:8];
    [_courseLabelArray addObject:self.courseNLabel];
    [_courseLabelArray addObject:self.courseNELabel];
    [_courseLabelArray addObject:self.courseELabel];
    [_courseLabelArray addObject:self.courseSELabel];
    [_courseLabelArray addObject:self.courseSLabel];
    [_courseLabelArray addObject:self.courseSWLabel];
    [_courseLabelArray addObject:self.courseWLabel];
    [_courseLabelArray addObject:self.courseNWLabel];
    

    [self updateUILanguageFont:[SystemManager getSystemLanguage]];
    
    
    self.color = [SystemConfig getUIColorValue:CONFIG_CP1_COLOR];
	// Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{

    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self inactive];
}
-(void) viewDidAppear:(BOOL)animated
{
    [self active];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tagAction:(id)sender
{
    if (_isShowCarPanelMenu)
    {
        [self hideCarPanelMenu];
    }
    else
    {
        [self showCarPanelMenu];
    }
}

-(void) active
{
    self.batteryLife    = [SystemManager getBatteryLife];
    self.networkStatus  = [SystemManager getNetworkStatus];
    self.speed          = 0;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [SystemManager addDelegate:self];
    [LocationManager addDelegate:self];
    [LocationManager startLocationTracking];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:UIDeviceBatteryLevelDidChangeNotification
     object:self];
    
    [self updateUILanguage];
    [self updateUIFromConfig];

    self.debugMsgLabel.hidden = ![SystemConfig getBoolValue:CONFIG_IS_DEBUG];
    [_clockView active];
    [_systemStatusView active];
    
}

-(void) inactive
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [SystemManager removeDelegate:self];
    [LocationManager removeDelegate:self];
    [LocationManager stopLocationTracking];
    
    [_clockView inactive];
    [_systemStatusView inactive];
    
}
- (void)viewDidUnload
{
    [self setContentView:nil];
    [self setSpeedLabel:nil];
    [self setSpeedUnitLabel:nil];
    [self setSpeedUnitLabel:nil];
    [self setCourseFrameImage:nil];
    [self setCourseSWLabel:nil];
    [self setCourseWLabel:nil];
    [self setCourseNWLabel:nil];
    [self setCourseNLabel:nil];
    [self setCourseNELabel:nil];
    [self setCourseELabel:nil];
    [self setCourseSELabel:nil];
    [self setCourseSLabel:nil];
    [self setCourseLabel:nil];
    [self setContentView:nil];
    [self setCourseView:nil];
    [self setDebugMsgLabel:nil];
    [super viewDidUnload];
}



#pragma mark - Update UI

-(void) addUIComponents
{
    
    _clockView                  = [[ClockView alloc] initWithFrame:CGRectMake(320 + [SystemManager lanscapeScreenRect].size.width - 480, 8, 120, 50)];
    _systemStatusView           = [[SystemStatusView alloc] initWithFrame:CGRectMake(0, 0, 180, 50)];
    
    [self.view addSubview:_clockView];
    [self.view addSubview:_systemStatusView];
}
-(void) updateUILanguage
{
    _carPanelMenuHudLabel.text      = [SystemManager getLanguageString:@"HUD"];
    _carPanelMenuCourseLabel.text   = [SystemManager getLanguageString:@"Course"];
    _carPanelMenuUnitLabel.text     = [SystemManager getLanguageString:@"Unit"];
}

-(void) updateUIFromConfig
{
    _carPanelMenuHudSwitch.on       = [SystemConfig getBoolValue:CONFIG_CP1_IS_HUD];
    _carPanelMenuCourseSwitch.on    = [SystemConfig getBoolValue:CONFIG_CP1_IS_COURSE];

    self.isHud          = _carPanelMenuHudSwitch.on;
    self.isCourse       = _carPanelMenuCourseSwitch.on;
    self.isSpeedUnitMph = [SystemConfig getBoolValue:CONFIG_CP1_IS_SPEED_UNIT_MPH];
    
    if (YES == self.isSpeedUnitMph)
    {
        
        [_carPanelMenuSpeedMphButton setBackgroundColor:[UIColor blueColor]];
        [_carPanelMenuSpeedKmhButton setBackgroundColor:[UIColor blackColor]];
    }
    else
    {
        [_carPanelMenuSpeedMphButton setBackgroundColor:[UIColor blackColor]];
        [_carPanelMenuSpeedKmhButton setBackgroundColor:[UIColor blueColor]];
    }
    
    [self updateColorFromConfig];
}
-(void) updateColorFromConfig
{
    int i;
    UIButton *button;
    UIColor *defaultColor;
    
    defaultColor = [SystemConfig getUIColorValue:CONFIG_CP1_COLOR];
    
    for( i=0; i<_colorButtons.count; i++)
    {
        button = [_colorButtons objectAtIndex:i];
        if ( YES == CGColorEqualToColor(button.backgroundColor.CGColor, defaultColor.CGColor))
        {
            [self setColorButtonSelected:button];
        }
        else
        {
            [self setColorButtonUnSelected:button];
        }
    }
}

-(void) setColorButtonSelected:(UIButton*) button
{
    
    CGRect buttonFrame;
    buttonFrame = button.frame;
    
    if (buttonFrame.size.width == _colorButtonUnselectedSize.width)
    {
        buttonFrame.origin.x -= (_colorButtonSelectedSize.width  - _colorButtonUnselectedSize.width)/2;
        buttonFrame.origin.y -= (_colorButtonSelectedSize.height - _colorButtonUnselectedSize.height)/2;
        buttonFrame.size      = _colorButtonSelectedSize;
        
        button.frame = buttonFrame;
        
        button.layer.borderColor    = [UIColor lightGrayColor].CGColor;

        button.layer.borderWidth    = 3.0f;
        button.layer.cornerRadius   = 5;
        button.layer.masksToBounds  = YES;
    }
}

-(void) setColorButtonUnSelected:(UIButton*) button
{
    CGRect buttonFrame;
    buttonFrame = button.frame;
    
    if (buttonFrame.size.width == _colorButtonSelectedSize.width)
    {
        buttonFrame.origin.x += (_colorButtonSelectedSize.width  - _colorButtonUnselectedSize.width)/2;
        buttonFrame.origin.y += (_colorButtonSelectedSize.height - _colorButtonUnselectedSize.height)/2;
        buttonFrame.size      = _colorButtonUnselectedSize;
        
        button.frame = buttonFrame;
        
        [button.layer setBorderWidth:0];
        
    }
}

-(void) placeCourseLabel
{
    float space;
    float labelOffset;
    int i;
    CGSize labelSize;
    UILabel *label;
    CGRect labelFrame;
    CGRect screenRect;
    
    screenRect  = [SystemManager lanscapeScreenRect];
    labelSize   = _courseNLabel.frame.size;
    
    if (screenRect.size.width > 480)
    {
        self.courseLabelRect = CGRectMake(0, 5, 508, labelSize.height);
    }
    else
    {
        self.courseLabelRect = CGRectMake(0, 5, 508 - (568-480), labelSize.height);
    }
    
    /*
     * |-------------------------------- \\ -----|
     * |--Label--|--space--|------ \\ -----|
     * |----Label offset --|
     */
    space = ((self.courseLabelRect.size.width) - (labelSize.width*_courseLabelArray.count))/(_courseLabelArray.count);
    
    labelOffset = labelSize.width + space;
    
    _courseAngleToPixelOffset   = self.courseLabelRect.size.width/(2*M_PI);
    _courseCenterNOffset        = self.courseLabelRect.size.width/2 - labelSize.width/2 - space/2.0;
    
    for(i=0; i<_courseLabelArray.count; i++)
    {
        label       = (UILabel*) [_courseLabelArray objectAtIndex:i];
        labelFrame  = CGRectMake(
                                 self.courseLabelRect.origin.x + i*labelOffset + (space/2.0),
                                 self.courseLabelRect.origin.y,
                                 labelSize.width,
                                 labelSize.height);
        label.frame = labelFrame;
        _courseLabelOrigins[i] = labelFrame.origin;
        
        label.text = [SystemManager getLanguageString:label.text];
    }
    
    self.courseCutLabel.frame = CGRectMake(-labelSize.width, labelFrame.origin.y, labelFrame.size.width, labelFrame.size.height);
    [self updateCourse];
    
}

-(void) updateCourse
{
    int i;
    UILabel *label;
    CGRect labelFrame;
    CGRect cutLabelFrame;
    
    float pixelToMove;
    
    cutLabelFrame           = _courseCutLabel.frame;
    pixelToMove             = _courseAngleToPixelOffset * _heading;
    cutLabelFrame.origin.x  = -100;
    
    for(i=0; i<_courseLabelArray.count; i++)
    {
        label       = (UILabel*) [_courseLabelArray objectAtIndex:i];
        labelFrame  = label.frame;
        labelFrame.origin = _courseLabelOrigins[i];
        labelFrame.origin.x += _courseCenterNOffset;
        labelFrame.origin.x -= pixelToMove;
        
        if (labelFrame.origin.x + labelFrame.size.width < 0)
        {
            labelFrame.origin.x     += _courseLabelRect.size.width;
        }
        else if (labelFrame.origin.x + labelFrame.size.width > _courseLabelRect.size.width)
        {
            labelFrame.origin.x     -= _courseLabelRect.size.width;
        }
        
        /* calculate cut lable position */
        if (  labelFrame.origin.x < 0 )
        {
            _courseCutLabel.text    = label.text;
            _courseCutLabel.font    = label.font;
            cutLabelFrame.origin.x  = labelFrame.origin.x + _courseLabelRect.size.width;
        }
        else if ((labelFrame.origin.x + labelFrame.size.width) > _courseLabelRect.size.width )
        {
            _courseCutLabel.text    = label.text;
            _courseCutLabel.font    = label.font;
            cutLabelFrame.origin.x  = labelFrame.origin.x - _courseLabelRect.size.width;
        }
        
        label.frame = labelFrame;
    }
    _courseCutLabel.frame = cutLabelFrame;
}


-(void) updateUILanguageFont:(NSString*) language
{
    
    if ([language isEqualToString:@"zh-Hant"])
    {
        self.speedUnitLabel.font = [self.speedUnitLabel.font newFontsize:15];
        
        self.courseNELabel.font = [self.courseNELabel.font newFontsize:16];
        self.courseNWLabel.font = [self.courseNWLabel.font newFontsize:16];
        self.courseSELabel.font = [self.courseSELabel.font newFontsize:16];
        self.courseSWLabel.font = [self.courseSWLabel.font newFontsize:16];
    }
}

#pragma mark - Property

-(void) setIsCourse:(BOOL)isCourse
{
    _isCourse = isCourse;
    _courseView.hidden = !_isCourse;
    
    _courseView.hidden = YES;
}

-(void) setIsHud:(BOOL)isHud
{
    _isHud = isHud;
    
    if(_isHud == TRUE)
    {
        self.contentView.transform = CGAffineTransformMakeScale(1,-1);
    }
    else
    {
        self.contentView.transform = CGAffineTransformMakeScale(1, 1);
    }
    
}

-(void) setColor:(UIColor*) color
{
    _color                      = color;
    _speedLabel.textColor       = _color;
    _speedUnitLabel.textColor   = _color;
    _clockView.color            = _color;
    _systemStatusView.color     = _color;
    
    
    if ( YES == [SystemConfig getBoolValue:CONFIG_IS_DEBUG])
    {
        _courseCutLabel.textColor   = _color;
    }
    
    [_courseFrameImage  setImageTintColor:_color];
    
    
    for (UILabel* l in _courseLabelArray)
    {
        l.textColor = _color;
    }
    
    [self placeCourseLabel];
}

-(void) setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    _isSpeedUnitMph = isSpeedUnitMph;
    
    if (YES == _isSpeedUnitMph)
    {
        self.speedUnitLabel.text = [SystemManager getLanguageString:@"mph"];
    }
    else
    {
        self.speedUnitLabel.text = [SystemManager getLanguageString:@"kmh"];
    }
}

-(void) setHeading:(double)heading
{
    _heading = heading;
    
    while (_heading >= 2*M_PI)
    {
        _heading -= 2*M_PI;
    }
    
    while (_heading < 0)
    {
        _heading += 2*M_PI;
    }
    
    [self updateCourse];
    
}

-(void) setSpeed:(double)speed
{
    if (speed < 0)
        speed = 0;
    
    if (speed > 999)
        speed = 999;
    
    if (isnan(speed))
    {
        speed = 0;
    }
    
    _speed = speed;
    _speedLabel.text = [NSString stringWithFormat:@"%.0f", speed];
}


#pragma mark - System Monitor

-(void) locationUpdate:(CLLocationCoordinate2D) location speed:(double) speed distance:(int) distance heading:(double) heading
{
    if (YES == _isSpeedUnitMph)
    {
        self.speed = MS_TO_MPH(speed);
    }
    else
    {
        self.speed = MS_TO_KMH(speed);
    }
    //    self.heading    = heading;
    
    self.debugMsgLabel.text = [NSString stringWithFormat:@"%.8f, %.8f, %.1f, %.1f",
                               location.latitude,
                               location.longitude,
                               speed,
                               heading
                               ];
    
}


-(void) lostLocationUpdate
{
    
}


#pragma mark - Car Panel Menu


-(void) addCarPanelMenu
{
    UIView *subView;
    UIButton *button;
    CGRect carPanelFrame;
    
    _isShowCarPanelMenu = false;
    
    NSArray *xibContents = [[NSBundle mainBundle] loadNibNamed:@"CarPanel1Menu" owner:self options:nil];
    
    subView = [xibContents lastObject];
    
    _carPanelMenu = [subView.subviews lastObject];
    _carPanelMenu.accessibilityLabel = @"carPanelMenu";
    
    mlogDebug(@"carPanelMenu: frame: (%.0f, %.0f) (%.0f, %.0f), bounds: (%.0f, %.0f) (%.0f, %.0f)\n",
              _carPanelMenu.frame.origin.x,
              _carPanelMenu.frame.origin.y,
              _carPanelMenu.frame.size.width,
              _carPanelMenu.frame.size.height,
              _carPanelMenu.bounds.origin.x,
              _carPanelMenu.bounds.origin.y,
              _carPanelMenu.bounds.size.width,
              _carPanelMenu.bounds.size.height
              );
    
    /* adjust center to center position */
    
    if ( 568 != [SystemManager lanscapeScreenRect].size.width)
    {
        carPanelFrame = _carPanelMenu.frame;
        carPanelFrame.origin.x = ([SystemManager lanscapeScreenRect].size.width - carPanelFrame.size.width)/2;
        _carPanelMenu.frame = carPanelFrame;
        
    }
    
    /* logo button */
    _carPanelMenuLogoButton = (UIButton *)[_carPanelMenu viewWithTag:1];
    [_carPanelMenuLogoButton addTarget:self
                                action:@selector(pressLogoButton:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    /* hud, course switch */
    _carPanelMenuHudLabel       = (UILabel *)[_carPanelMenu viewWithTag:201];
    _carPanelMenuCourseLabel    = (UILabel *)[_carPanelMenu viewWithTag:202];
    _carPanelMenuUnitLabel      = (UILabel *)[_carPanelMenu viewWithTag:203];
    
    _carPanelMenuHudSwitch      = (UISwitch *)[_carPanelMenu viewWithTag:301];
    _carPanelMenuCourseSwitch   = (UISwitch *)[_carPanelMenu viewWithTag:302];
    
    [_carPanelMenuHudSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [_carPanelMenuCourseSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    _carPanelMenuSpeedMphButton   = (UIButton *)[_carPanelMenu viewWithTag:303];
    _carPanelMenuSpeedKmhButton   = (UIButton *)[_carPanelMenu viewWithTag:304];
    
    [_carPanelMenuSpeedMphButton addTarget:self
                                action:@selector(pressMphButton:)
                      forControlEvents:UIControlEventTouchUpInside];

    [_carPanelMenuSpeedKmhButton addTarget:self
                                action:@selector(pressKmhButton:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    
    /* color buttons */
    button = (UIButton*)[_carPanelMenu viewWithTag:101];
    [button addTarget:self
               action:@selector(pressColorButton:)
     forControlEvents:UIControlEventTouchUpInside];
    [_colorButtons addObject:button];
    
    button = (UIButton*)[_carPanelMenu viewWithTag:102];
    [button addTarget:self
               action:@selector(pressColorButton:)
     forControlEvents:UIControlEventTouchUpInside];
    [_colorButtons addObject:button];
    
    button = (UIButton*)[_carPanelMenu viewWithTag:103];
    [button addTarget:self
               action:@selector(pressColorButton:)
     forControlEvents:UIControlEventTouchUpInside];
    [_colorButtons addObject:button];
    
    button = (UIButton*)[_carPanelMenu viewWithTag:104];
    [button addTarget:self
               action:@selector(pressColorButton:)
     forControlEvents:UIControlEventTouchUpInside];
    [_colorButtons addObject:button];
    
    button = (UIButton*)[_carPanelMenu viewWithTag:105];
    [button addTarget:self
               action:@selector(pressColorButton:)
     forControlEvents:UIControlEventTouchUpInside];
    [_colorButtons addObject:button];
    
    
    _colorButtonUnselectedSize  = button.frame.size;
    _colorButtonSelectedSize    = _colorButtonUnselectedSize;
    _colorButtonSelectedSize.width  += 16;
    _colorButtonSelectedSize.height += 16;
    
    _carPanelMenu.hidden = true;
    
    _carPanelMenu.layer.borderColor    = [UIColor whiteColor].CGColor;
    _carPanelMenu.layer.borderWidth    = 3.0f;
    _carPanelMenu.layer.cornerRadius   = 10;
    _carPanelMenu.layer.masksToBounds  = YES;
    
    [self.view addSubview:_carPanelMenu];
    
}

-(IBAction) pressLogoButton:(id) sender
{
    
    [self hideCarPanelMenu];
    [LocationManager stopLocationSimulation];
    [self dismissModalViewControllerAnimated:YES];
}


-(IBAction) pressColorButton:(id) sender
{
    UIButton *button = (UIButton*) sender;
    
    [SystemConfig setValue:CONFIG_CP1_COLOR uicolor:button.backgroundColor];
    self.color = [SystemConfig getUIColorValue:CONFIG_CP1_COLOR];
    [self updateColorFromConfig];
}

-(IBAction) pressHudButton:(id) sender
{
    [self hideCarPanelMenu];
    self.isHud = !self.isHud;
}

-(IBAction) pressMphButton:(id) sender
{
    [SystemConfig setValue:CONFIG_CP1_IS_SPEED_UNIT_MPH BOOL:TRUE];
    [self updateUIFromConfig];
    
}

-(IBAction) pressKmhButton:(id) sender
{
    
    [SystemConfig setValue:CONFIG_CP1_IS_SPEED_UNIT_MPH BOOL:FALSE];
    [self updateUIFromConfig];
}

-(IBAction) switchValueChanged:(id) sender
{
    if (sender == _carPanelMenuHudSwitch)
    {
        [SystemConfig setValue:CONFIG_CP1_IS_HUD BOOL:_carPanelMenuHudSwitch.on];
    }
    else if (sender == _carPanelMenuCourseSwitch)
    {
        [SystemConfig setValue:CONFIG_CP1_IS_COURSE BOOL:_carPanelMenuCourseSwitch.on];
    }
    
    [self updateUIFromConfig];
}

-(void) showCarPanelMenu
{
    if (!_isShowCarPanelMenu)
    {

        _carPanelMenu.hidden    = FALSE;
        _isShowCarPanelMenu     = TRUE;
    }
}

-(void) hideCarPanelMenu
{
    if (_isShowCarPanelMenu)
    {
        _carPanelMenu.hidden  = TRUE;
        _isShowCarPanelMenu   = FALSE;
    }
}

@end
