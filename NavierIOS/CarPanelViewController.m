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
#import "LocationUpdateEvent.h"

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
    CarPanelMenuView            *carPanelMenuView;
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
    CarPanelSetting*            setting;
    
}

@property (nonatomic) float batteryLife;
@property (nonatomic) BOOL networkEnabled;
@property (nonatomic) BOOL gpsEnabled;

@property (nonatomic, assign) double batteryStatus;

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

    [super viewDidLoad];
    setting             = [[CarPanelSetting alloc] initWithName:self.carPanelName];
    self.contentView    = (UIView<CarPanelViewProtocol>*)[self.view viewWithTag:10];
    tapGesture          = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self addCarPanelMenu];

    self.lockColorSelection = FALSE;
    
    headingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateHeading)
                                   userInfo:nil
                                    repeats:YES];


    [self updateUIFromSetting];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLocationUpdateEvent:)
                                                 name:LOCATION_MANAGER_LOCATION_UPDATE_EVENT
                                               object:nil];
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
    [GoogleUtil sendScreenView:self.carPanelName];
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

-(void) updateUIFromSetting
{
    carPanelMenuHudSwitch.on       = setting.isHud;
    carPanelMenuCourseSwitch.on    = setting.isCourse;
    
    self.isHud          = setting.isHud;
    self.isSpeedUnitMph = setting.isSpeedUnitMph;
    
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

    self.color = setting.selPrimaryColor;
}

-(void)updateSystemStatus
{
    self.batteryLife       = [SystemManager getBatteryLife];
    self.networkEnabled    = [SystemManager getNetworkStatus] > 0;
    self.gpsEnabled        = [SystemManager getGpsStatus] > 0 ? TRUE:FALSE;
    
}

#pragma mark -- Property
-(void)setColor:(UIColor *)color
{
    _color = color;
    self.contentView.color = self.color;
    setting.selPrimaryColor = color;

    if([self.contentView respondsToSelector:@selector(setSecondaryColor:)])
    {
        [self.contentView setSecondaryColor:[setting secondaryColorByPrimaryColor:self.color]];
    }
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
    _isSpeedUnitMph         = isSpeedUnitMph;
    setting.isSpeedUnitMph  = self.isSpeedUnitMph;

    if ([self.contentView respondsToSelector:@selector(setIsSpeedUnitMph:)])
    {
        [self.contentView setIsSpeedUnitMph:self.isSpeedUnitMph];
    }
}

-(void)setIsHud:(BOOL)isHud
{
    _isHud = isHud;
    setting.isHud = self.isHud;
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

-(void)setBatteryLife:(float)batteryLife
{
    _batteryLife = batteryLife;
    
    if ([self.contentView respondsToSelector:@selector(setBatteryLife:)])
    {
        [self.contentView setBatteryLife:self.batteryLife];
    }
}

-(void)setNetworkEnabled:(BOOL)networkEnabled
{
    _networkEnabled = networkEnabled;
    if ([self.contentView respondsToSelector:@selector(setNetworkEnabled:)])
    {
        [self.contentView setNetworkEnabled:self.networkEnabled];
    }
}

-(void)setGpsEnabled:(BOOL)gpsEnabled
{
    _gpsEnabled = gpsEnabled;
    if ([self.contentView respondsToSelector:@selector(setGpsEnabled:)])
    {
        [self.contentView setGpsEnabled:self.gpsEnabled];
    }
}

#pragma mark - Car Panel Menu


-(void) addCarPanelMenu
{
    NSArray *xibContents                = [[NSBundle mainBundle] loadNibNamed:@"CarPanelMenuView" owner:self options:nil];
    carPanelMenuView                    = [xibContents lastObject];
    carPanelMenuView.accessibilityLabel = @"carPanelMenuView";
    carPanelMenuView.delegate           = self;
    
    carPanelMenuView.isHud              = setting.isHud;
    carPanelMenuView.isSpeedUnitMph     = setting.isSpeedUnitMph;

    
    carPanelMenuView.panelColor1Button.backgroundColor = [[setting primaryColors] objectAtIndex:0];
    carPanelMenuView.panelColor2Button.backgroundColor = [[setting primaryColors] objectAtIndex:1];
    carPanelMenuView.panelColor3Button.backgroundColor = [[setting primaryColors] objectAtIndex:2];
    carPanelMenuView.panelColor4Button.backgroundColor = [[setting primaryColors] objectAtIndex:3];
    carPanelMenuView.panelColor5Button.backgroundColor = [[setting primaryColors] objectAtIndex:4];
    
    
    carPanelMenuView.panelColor         = setting.selPrimaryColor;
    
    
    [self.view addSubview:carPanelMenuView];
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
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:UIDeviceBatteryLevelDidChangeNotification
     object:self];
    
    [self updateUIFromSetting];
    [self updateSystemStatus];
    [self.contentView active];
}

-(void) inactive
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [SystemManager removeDelegate:self];
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
-(void) carPanel1MenuView:(CarPanelMenuView*) cpm changeColor:(UIColor*) color
{
    self.color = color;
}

-(void) carPanel1MenuView:(CarPanelMenuView*) cpm changeHud:(BOOL) isHud
{
    self.isHud = isHud;
}

-(void) carPanel1MenuView:(CarPanelMenuView*) cpm changeSpeedUnit:(BOOL) isMph
{
    self.isSpeedUnitMph = isMph;
}

-(void) carPanel1MenuView:(CarPanelMenuView*) cpm pressLogoButton:(BOOL) isPressed
{
    if (YES == isPressed)
    {
        [self dismiss];
    }
}

-(void) carPanel1MenuView:(CarPanelMenuView*) cpm pressCloseButton:(BOOL) isPressed
{
    if (YES == isPressed)
    {
        carPanelMenuView.hidden = YES;
    }
}

-(void) carPanel1MenuView:(CarPanelMenuView*) cpm pressBuyButton:(BOOL) isPressed
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
    if (YES == self.isSpeedUnitMph)
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

-(void) networkStatusChangeWifi:(float) wifiStatus threeG:(float) threeGStatus
{
    self.networkEnabled= (wifiStatus + threeGStatus) > 0;
}


-(void) batteryStatusChange:(float) status
{
    self.batteryLife = status;
}

-(void) gpsStatusChange:(float) status
{
    self.gpsEnabled = status > 0 ? TRUE:FALSE;
}

#pragma mark -- notification

- (void)receiveLocationUpdateEvent:(NSNotification *)notification
{
    LocationUpdateEvent *event;
    event = [notification.userInfo objectForKey:@"data"];
    [self locationManager:NULL update:event.location speed:event.speed distance:event.distance heading:event.heading];
}

#pragma mark -- Test
-(void)updateHeading
{
    static double angle = 0;
    self.heading = angle;
    angle += TO_RADIUS(10);
}
@end
