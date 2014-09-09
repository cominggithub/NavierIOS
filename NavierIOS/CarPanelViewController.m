//
//  CarPanelViewController.m
//  NavierIOS
//
//  Created by Coming on 7/23/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanelViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <NaviUtil/NaviUtil.h>
#import "BuyUIViewController.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG FALSE
#else
#define FILE_DEBUG FALSE
#endif

#include "Log.h"




@interface CarPanelViewController ()
{
    CarPanel1MenuView           *carPanelMenuView;
    UIButton                    *carPanelMenuLogoButton;
    UIButton                    *carPanelMenuHudButton;
    UIButton                    *carPanelMenuSpeedMphButton;
    UIButton                    *carPanelMenuSpeedKmhButton;
    UILabel                     *carPanelMenuHudLabel;
    UILabel                     *carPanelMenuCourseLabel;
    UILabel                     *carPanelMenuUnitLabel;
    UISwitch                    *carPanelMenuHudSwitch;
    UISwitch                    *carPanelMenuCourseSwitch;
    UITapGestureRecognizer      *tapGesture;
    
    NSTimer*                    headingTimer;
    NSMutableArray              *colorButtons;
}


@end

@implementation CarPanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    logfn();
    [super viewDidLoad];
    self.contentView    = (UIView<CarPanelViewProtocol>*)[self.view viewWithTag:10];
    logO(self.contentView);
    tapGesture          = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self addCarPanelMenu];

    self.lockColorSelection = FALSE;
    
//    headingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                     target:self
//                                   selector:@selector(updateHeading)
//                                   userInfo:nil
//                                    repeats:YES];


    
    // Do any additional setup after loading the view.
    [self updateUIFromConfig];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = TRUE;
    [self active];
    [self checkIapItem];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self inactive];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
#pragma mark -- Update UI

-(void) updateUIFromConfig
{
    carPanelMenuHudSwitch.on       = [SystemConfig getBoolValue:CONFIG_CP1_IS_HUD];
    carPanelMenuCourseSwitch.on    = [SystemConfig getBoolValue:CONFIG_CP1_IS_COURSE];
    
    self.isHud          = carPanelMenuHudSwitch.on;
    self.isSpeedUnitMph = [SystemConfig getBoolValue:CONFIG_CP1_IS_SPEED_UNIT_MPH];
    
    if (YES == self.isSpeedUnitMph)
    {
        
        [carPanelMenuSpeedMphButton setBackgroundColor:[UIColor blueColor]];
        [carPanelMenuSpeedKmhButton setBackgroundColor:[UIColor blackColor]];
    }
    else
    {
        [carPanelMenuSpeedMphButton setBackgroundColor:[UIColor blackColor]];
        [carPanelMenuSpeedKmhButton setBackgroundColor:[UIColor blueColor]];
    }

    self.color = [SystemConfig getUIColorValue:CONFIG_CP1_COLOR];
}

#pragma mark -- Property
-(void)setColor:(UIColor *)color
{
    _color = color;
    self.contentView.color = self.color;
}

-(void)setLockColorSelection:(BOOL)lockColorSelection
{
    _lockColorSelection = lockColorSelection;
    carPanelMenuView.lockColorSelection = self.lockColorSelection;
}


-(void)setSpeed:(double)speed
{
    if ([self.contentView respondsToSelector:@selector(setSpeed:)])
    {
        [self.contentView setSpeed:speed];
    }
}

-(void)setHeading:(double)heading
{
    if ([self.contentView respondsToSelector:@selector(setHeading:)])
    {
        [self.contentView setHeading:heading];
    }
}

-(void)setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    if ([self.contentView respondsToSelector:@selector(setIsSpeedUnitMph:)])
    {
        [self.contentView setIsSpeedUnitMph:isSpeedUnitMph];
    }
}

-(void)setIsHud:(BOOL)isHud
{
    _isHud = isHud;
    if ([self.contentView respondsToSelector:@selector(setIsHud:)])
    {
        [self.contentView setIsHud:isHud];
    }
    
    if (self.isHud)
    {
        [[UIScreen mainScreen] setBrightness:1.0];
    }
    else
    {
        [[UIScreen mainScreen] setBrightness:[SystemConfig getFloatValue:CONFIG_DEFAULT_BRIGHTNESS]];
    }
    
}

-(void)setLocation:(CLLocationCoordinate2D)location
{
    if ([self.contentView respondsToSelector:@selector(setLocation:)])
    {
        [self.contentView setLocation:location];
    }
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
    carPanelMenuView.panelColor         = [SystemConfig getUIColorValue:CONFIG_CP1_COLOR];
    
    [self.view addSubview:carPanelMenuView];
}

-(IBAction) pressLogoButton:(id) sender
{
    
    [self hideCarPanelMenu];
    [self.navigationController popViewControllerAnimated:TRUE];
}


-(IBAction) pressColorButton:(id) sender
{
    UIButton *button = (UIButton*) sender;
    
    [SystemConfig setValue:CONFIG_CP1_COLOR uicolor:button.backgroundColor];
    self.color = [SystemConfig getUIColorValue:CONFIG_CP1_COLOR];
 
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
    if (sender == carPanelMenuHudSwitch)
    {
        [SystemConfig setValue:CONFIG_CP1_IS_HUD BOOL:carPanelMenuHudSwitch.on];
    }
    else if (sender == carPanelMenuCourseSwitch)
    {
        [SystemConfig setValue:CONFIG_CP1_IS_COURSE BOOL:carPanelMenuCourseSwitch.on];
    }
    
    [self updateUIFromConfig];
}

-(void) showCarPanelMenu
{
    [SoundUtil playPopup];
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

#pragma -- Operation
-(void) active
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [SystemManager addDelegate:self];
    [LocationManager addDelegate:self];
    [self updateUIFromConfig];
    [self.contentView active];
}

-(void) inactive
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [SystemManager removeDelegate:self];
    [LocationManager removeDelegate:self];
    [self.contentView inactive];
}

-(void) checkIapItem
{
//    carPanelMenuView.lockColorSelection = ![SystemConfig getBoolValue:CONFIG_IAP_IS_ADVANCED_VERSION];
}

-(void)dismiss
{
    [self hideCarPanelMenu];
    [self.navigationController popToRootViewControllerAnimated:TRUE];
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
        [self dismiss];
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

    carPanelMenuView.hidden = YES;
}

- (IBAction)tapAction:(UITapGestureRecognizer *)recognizer
{

    if (!CGRectContainsPoint(carPanelMenuView.bounds, [recognizer locationInView:carPanelMenuView]))
    {
        if (YES == carPanelMenuView.hidden)
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

-(void) locationManager:(LocationManager *)locationManager update:(CLLocationCoordinate2D)location speed:(double)speed distance:(int)distance heading:(double)heading
{
    if (YES == _isSpeedUnitMph)
    {
        self.speed = MS_TO_MPH(speed);
    }
    else
    {
        self.speed = MS_TO_KMH(speed);
    }
    
    self.heading = heading;
    self.location = location;
    
    mlogDebug(@"location update: %.8f, %.8f heading: %.1f", location.latitude, location.longitude, TO_ANGLE(heading));

}

#pragma mark -- Test
-(void)updateHeading
{
    static double angle = 0;
    self.heading = angle;
    angle += TO_RADIUS(10);
}
@end
