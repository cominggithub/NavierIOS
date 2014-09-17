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
#import "CarPanel1MenuView.h"
#import "BuyUIViewController.h"
#import "GoogleUtil.h"
#import "LocationUpdateEvent.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"


@interface CarPanel1ViewController ()
{
    CarPanel1UIView             *_carPanel1;
    NSTimer                     *_redrawTimer;
    int                         _redrawInterval;
    NSMutableArray              *_courseLabelArray;
    ClockView                   *_clockView;
    SystemStatusView            *_systemStatusView;
    float                       _courseAngleToPixelOffset;
    CGPoint                     _courseLabelOrigins[8];
    float                       _courseCenterNOffset;
    BOOL                        _isShowCarPanelMenu;
    CarPanel1MenuView           *carPanelMenuView;
    UIButton                    *_carPanelMenuLogoButton;
    UIButton                    *_carPanelMenuHudButton;
    UIButton                    *_carPanelMenuSpeedMphButton;
    UIButton                    *_carPanelMenuSpeedKmhButton;
    UILabel                     *_carPanelMenuHudLabel;
    UILabel                     *_carPanelMenuCourseLabel;
    UILabel                     *_carPanelMenuUnitLabel;
    UISwitch                    *_carPanelMenuHudSwitch;
    UISwitch                    *_carPanelMenuCourseSwitch;
    NSMutableArray              *_colorButtons;
    CGSize                      _colorButtonUnselectedSize;
    CGSize                      _colorButtonSelectedSize;
    BuyUIViewController         *buyViewController;
    UIAlertView                 *alert;
    ADBannerView                *adView;
    BOOL                        bannerIsVisible;
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
    UIStoryboard *storyboard;
    
    _redrawInterval     = 0.5;
    _redrawTimer        = nil;
    _colorButtons       = [[NSMutableArray alloc] initWithCapacity:5];
    storyboard          = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    buyViewController   = (BuyUIViewController *)[storyboard instantiateViewControllerWithIdentifier:NSStringFromClass ([BuyUIViewController class])];

    
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
    

//    [self updateUILanguageFont:[SystemManager getSystemLanguage]];
    
    
    self.color          = [SystemConfig getUIColorValue:CONFIG_CP1_COLOR];
    self.isHud          = [SystemConfig getBoolValue:CONFIG_CP1_IS_HUD];
    self.isSpeedUnitMph = [SystemConfig getBoolValue:CONFIG_CP1_IS_SPEED_UNIT_MPH];
    
    /* banner */
    [self addBanner:self.contentView];
    [self showAdAnimated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLocationUpdateEvent:)
                                                 name:LOCATION_MANAGER_LOCATION_UPDATE_EVENT
                                               object:nil];
    
    
}

-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = TRUE;
    self.debugMsgLabel.hidden = ![SystemConfig getBoolValue:CONFIG_H_IS_DEBUG];
    [self active];
    [self checkIapItem];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self inactive];
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GoogleUtil sendScreenView:@"Car Panel 1"];

}

-(void) viewDidDisappear:(BOOL)animated
{
    [[UIScreen mainScreen] setBrightness:[SystemConfig getFloatValue:CONFIG_DEFAULT_BRIGHTNESS]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) active
{
    self.batteryLife    = [SystemManager getBatteryLife];
    self.networkStatus  = [SystemManager getNetworkStatus];
    self.speed          = 0;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [SystemManager addDelegate:self];
//    [LocationManager addDelegate:self];
    
    if (YES == [SystemConfig getBoolValue:CONFIG_IS_TRACK_LOCATION])
    {
        [LocationManager startLocationTracking];
    }
    
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:UIDeviceBatteryLevelDidChangeNotification
     object:self];
    
    [self updateUILanguage];

    [self updateColorFromConfig];

    [_clockView active];
    [_systemStatusView active];

    self.msgLabel.hidden    = FALSE;
    self.msgLabel.text      = [SystemManager getLanguageString:@"No GPS Signal"];
}

-(void) inactive
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [SystemManager removeDelegate:self];
//    [LocationManager removeDelegate:self];
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

#pragma  mark - Banner
-(void) addBanner:(UIView*) contentView
{
    if (FALSE == [SystemConfig getBoolValue:CONFIG_H_IS_AD])
        return;
    
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)])
    {
        adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else
    {
        adView = [[ADBannerView alloc] init];
    }
    
    [adView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    adView.delegate                            = self;
    adView.accessibilityLabel                  = @"banner";
    
    
    [self.view addSubview:adView];
    
    [self showAdAnimated:NO];
}

- (void)showAdAnimated:(BOOL)animated
{
    
    if (nil == adView)
        return;
    
    CGRect bannerFrame      = adView.frame;
    
    if (adView.bannerLoaded && bannerIsVisible)
    {
        bannerFrame.origin.y = self.contentView.frame.size.height-adView.frame.size.height;
        
    } else
    {
        bannerFrame.origin.y  = self.contentView.frame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        adView.frame        = bannerFrame;
    }];
    
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    
    [self showAdAnimated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self showAdAnimated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    BOOL shouldExecuteAction = true; // your application implements this method
    
    if (!willLeave && shouldExecuteAction)
    {
        // insert code here to suspend any services that might conflict with the advertisement
    }
    
    return shouldExecuteAction;
    
    return false;
}



- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
}




#pragma mark - Update UI

-(void) addUIComponents
{
    
    _clockView                  = [[ClockView alloc] initWithFrame:CGRectMake([SystemManager lanscapeScreenRect].size.width - 160 - 8, 8, 160, 50)];
    _systemStatusView           = [[SystemStatusView alloc] initWithFrame:CGRectMake(0, 0, 180, 50)];
    
    [self.contentView addSubview:_clockView];
    [self.contentView addSubview:_systemStatusView];
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

    if (_colorButtons.count < 1)
    {
        return;
    }
    
    button = [_colorButtons objectAtIndex:0];
    if ([SystemConfig getBoolValue:CONFIG_IAP_IS_ADVANCED_VERSION])
    {
        defaultColor = [SystemConfig getUIColorValue:CONFIG_CP1_COLOR];
    }
    else
    {
        defaultColor = button.backgroundColor;
    }
    
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
#if 0
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
#endif
    
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
        [[UIScreen mainScreen] setBrightness:1.0];
    }
    else
    {
        self.contentView.transform = CGAffineTransformMakeScale(1, 1);
        [[UIScreen mainScreen] setBrightness:[SystemConfig getFloatValue:CONFIG_DEFAULT_BRIGHTNESS]];
    }
}

-(void) setColor:(UIColor*) color
{
    _color                      = color;
    _speedLabel.textColor       = _color;
    _speedUnitLabel.textColor   = _color;
    _clockView.color            = _color;
    _systemStatusView.color     = _color;
    _msgLabel.textColor         = _color;
    
    
    if (YES == [SystemConfig getBoolValue:CONFIG_H_IS_DEBUG])
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
        self.speedUnitLabel.text = @"mph";
    }
    else
    {
        self.speedUnitLabel.text = @"km/h";
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
//    _speedLabel.text = @"116";
}


#pragma mark - System Monitor


-(void) locationManager:(LocationManager *)locationManager update:(CLLocationCoordinate2D)location speed:(double)speed distance:(int)distance heading:(double)heading
{
    self.msgLabel.hidden    = TRUE;
    
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

#pragma mark - Car Panel Menu


-(void) addCarPanelMenu
{
    NSArray *xibContents                = [[NSBundle mainBundle] loadNibNamed:@"CarPanel1MenuView" owner:self options:nil];
    carPanelMenuView                    = [xibContents lastObject];
    carPanelMenuView.accessibilityLabel = @"carPanel1MenuView";
    carPanelMenuView.delegate           = self;
    
    carPanelMenuView.isHud              = [SystemConfig getBoolValue:CONFIG_CP1_IS_HUD];
    carPanelMenuView.isSpeedUnitMph     = [SystemConfig getBoolValue:CONFIG_CP1_IS_SPEED_UNIT_MPH];

    if (![SystemConfig getBoolValue:CONFIG_IAP_IS_ADVANCED_VERSION])
    {
        [SystemConfig setValue:CONFIG_CP1_COLOR uicolor:[UIColor greenColor]];
    }
    
    carPanelMenuView.panelColor         = [SystemConfig getUIColorValue:CONFIG_CP1_COLOR];

    [self.view addSubview:carPanelMenuView];
}

-(IBAction) pressLogoButton:(id) sender
{
    
    [self hideCarPanelMenu];
    [self inactive];

    [self.navigationController popViewControllerAnimated:TRUE];
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
    carPanelMenuView.hidden = NO;
}

-(void) hideCarPanelMenu
{
    carPanelMenuView.hidden = YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


#pragma mark -- delegate
-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm changeColor:(UIColor*) color
{
    [SystemConfig setValue:CONFIG_CP1_COLOR uicolor:color];
    self.color = [SystemConfig getUIColorValue:CONFIG_CP1_COLOR];
}

-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm changeHud:(BOOL) isHud
{
    [SystemConfig setValue:CONFIG_CP1_IS_HUD BOOL:isHud];
    self.isHud = [SystemConfig getBoolValue:CONFIG_CP1_IS_HUD];
}

-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm changeSpeedUnit:(BOOL) isMph
{

    [SystemConfig setValue:CONFIG_CP1_IS_SPEED_UNIT_MPH BOOL:isMph];
    self.isSpeedUnitMph = [SystemConfig getBoolValue:CONFIG_CP1_IS_SPEED_UNIT_MPH];
}

-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm pressLogoButton:(BOOL) isPressed
{
    if (YES == isPressed)
    {
        [self hideCarPanelMenu];
        [self inactive];
        [self.navigationController popToRootViewControllerAnimated:TRUE];
    }
}

-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm pressCloseButton:(BOOL) isPressed
{
    if (YES == isPressed)
    {
        carPanelMenuView.hidden = YES;
    }
}

-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm pressBuyButton:(BOOL) isPressed
{
    if (YES == isPressed)
    {
        if (NavierHUDIAPHelper.iapItemCount > 0)
        {
            [self.navigationController pushViewController:buyViewController animated:TRUE];
        }
        else
        {
            [self showAlertTitle:[SystemManager getLanguageString:@"Cannot retrieve IAP items"]
                          message:[SystemManager getLanguageString:@"Forget to enable network connections?"]];
        }
    }
    
    carPanelMenuView.hidden = YES;
}

- (IBAction)tagAction:(id)sender
{

   UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer*)sender;
    
    if (!CGRectContainsPoint(carPanelMenuView.bounds, [tapRecognizer locationInView:carPanelMenuView]))
    {
        if (carPanelMenuView.hidden == TRUE)
        {
            [SoundUtil playPopup];
        }
        carPanelMenuView.hidden = !carPanelMenuView.hidden;
    }
    else if (carPanelMenuView.hidden)
    {
        [SoundUtil playPopup];
        carPanelMenuView.hidden = NO;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    alert = nil;
}

#pragma mark -- operation
- (void)checkIapItem
{
    bannerIsVisible                     = [SystemConfig getBoolValue:CONFIG_H_IS_AD] && (![SystemConfig getBoolValue:CONFIG_IAP_IS_ADVANCED_VERSION]);
    carPanelMenuView.lockColorSelection = ![SystemConfig getBoolValue:CONFIG_IAP_IS_ADVANCED_VERSION];
}

-(void) showAlertTitle:(NSString*) title message:(NSString*) message
{
    if (nil == alert)
    {
        alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:[SystemManager getLanguageString:@"OK"] otherButtonTitles:nil,nil];
        [alert show];
    }
}

#pragma mark -- notification

- (void)receiveLocationUpdateEvent:(NSNotification *)notification
{
    LocationUpdateEvent *event;
    event = [notification.userInfo objectForKey:@"data"];
    [self locationManager:NULL update:event.location speed:event.speed distance:event.distance heading:event.heading];
}

@end
