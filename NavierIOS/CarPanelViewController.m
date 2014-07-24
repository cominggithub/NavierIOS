//
//  CarPanelViewController.m
//  NavierIOS
//
//  Created by Coming on 7/23/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanelViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <NaviUtil/SystemConfig.h>
#import "BuyUIViewController.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
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
    [super viewDidLoad];

    self.contentView    = (UIView<CarPanelViewProtocol>*)[self.view viewWithTag:10];
    tapGesture          = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self addCarPanelMenu];
    [self updateColorFromConfig];
    self.lockColorSelection = FALSE;

    
    // Do any additional setup after loading the view.
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
    [self active];
    [self checkIapItem];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self inactive];
}

#pragma mark -- Update UI

-(void) updateUIFromConfig
{

}

-(void)updateColorFromConfig
{

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
    [self inactive];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction) pressColorButton:(id) sender
{
    UIButton *button = (UIButton*) sender;
    
    [SystemConfig setValue:CONFIG_CP1_COLOR uicolor:button.backgroundColor];
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
    [SystemManager addDelegate:self];
    [LocationManager addDelegate:self];
    [self updateUIFromConfig];
}

-(void) inactive
{
    [SystemManager removeDelegate:self];
    [LocationManager removeDelegate:self];}

-(void) checkIapItem
{

}

-(void)dismiss
{
   
    [self hideCarPanelMenu];
    [self inactive];
    [self dismissViewControllerAnimated:YES completion:nil];
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
        [self dismissViewControllerAnimated:YES completion:nil];
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

        carPanelMenuView.hidden = !carPanelMenuView.hidden;
    }
    else if (carPanelMenuView.hidden)
    {

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
    
    mlogDebug(@"location update: %.8f, %.8f heading: %.1f", location.latitude, location.longitude, TO_ANGLE(heading));

}

@end
