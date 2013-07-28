//
//  RouteNavigationViewController.m
//  NavierIOS
//
//  Created by Coming on 13/6/3.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "RouteNavigationViewController.h"

#define FILE_DEBUG TRUE
#include <NaviUtil/Log.h>

@interface RouteNavigationViewController ()

@end

@implementation RouteNavigationViewController
{
    BOOL isShowRouteGuideMenu;
    BOOL _isShowKeyboard;
    int routeGuideMenuOffset;
    UIView *routeGuideMenu;
    
    UIButton *routeGuideMenuLogoButton;
    UIButton *routeGuideMenuHUDButton;
    UIButton *routeGuideMenuSettingButton;
    
    UITextField *redTextField;
    UITextField *greenTextField;
    UITextField *blueTextField;
    UITextField *alphaTextField;
    UIView *colorPanel;
    
}

-(void) addRouteGuideMenu
{
    UIView *subView;
    isShowRouteGuideMenu = false;
    
    NSArray *xibContents = [[NSBundle mainBundle] loadNibNamed:@"RouteGuideMenu" owner:self options:nil];
    
    subView = [xibContents lastObject];
    
    routeGuideMenu = [subView.subviews lastObject];
    routeGuideMenu.accessibilityLabel = @"routeGuideMenu";
    routeGuideMenuOffset = 100;

    mlogDebug(@"RouteGuideMenu: frame: (%.0f, %.0f) (%.0f, %.0f), bounds: (%.0f, %.0f) (%.0f, %.0f)\n",
           routeGuideMenu.frame.origin.x,
           routeGuideMenu.frame.origin.y,
           routeGuideMenu.frame.size.width,
           routeGuideMenu.frame.size.height,
           routeGuideMenu.bounds.origin.x,
           routeGuideMenu.bounds.origin.y,
           routeGuideMenu.bounds.size.width,
           routeGuideMenu.bounds.size.height
           );


    routeGuideMenuLogoButton        = (UIButton *)[routeGuideMenu viewWithTag:1];
    routeGuideMenuHUDButton         = (UIButton *)[routeGuideMenu viewWithTag:2];
    routeGuideMenuSettingButton     = (UIButton *)[routeGuideMenu viewWithTag:3];

    
    [routeGuideMenuLogoButton addTarget:self
                               action:@selector(pressLogoButton:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [routeGuideMenuHUDButton addTarget:self
                             action:@selector(pressHUDButton:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [routeGuideMenuSettingButton addTarget:self
                                 action:@selector(pressSettingButton:)
                       forControlEvents:UIControlEventTouchUpInside];
   
    redTextField    = (UITextField *)[routeGuideMenu viewWithTag:101];
    greenTextField  = (UITextField *)[routeGuideMenu viewWithTag:102];
    blueTextField   = (UITextField *)[routeGuideMenu viewWithTag:103];
    alphaTextField  = (UITextField *)[routeGuideMenu viewWithTag:104];
    colorPanel  = (UIView *)[routeGuideMenu viewWithTag:105];
    
    redTextField.delegate       = self;
    greenTextField.delegate     = self;
    blueTextField.delegate      = self;
    alphaTextField.delegate     = self;    
    
    
    [redTextField addTarget:self
                     action:@selector(beginShowKeyboard:)
           forControlEvents:UIControlEventEditingDidBegin];
    
    [greenTextField addTarget:self
                     action:@selector(beginShowKeyboard:)
           forControlEvents:UIControlEventEditingDidBegin];
    
    [blueTextField addTarget:self
                     action:@selector(beginShowKeyboard:)
           forControlEvents:UIControlEventEditingDidBegin];
    
    [alphaTextField addTarget:self
                     action:@selector(beginShowKeyboard:)
           forControlEvents:UIControlEventEditingDidBegin];

    
    routeGuideMenu.hidden = true;
  
    routeGuideMenu.layer.borderColor    = [UIColor whiteColor].CGColor;
    routeGuideMenu.layer.borderWidth    = 3.0f;
    routeGuideMenu.layer.cornerRadius   = 10;
    routeGuideMenu.layer.masksToBounds  = YES;
  
    [self.view addSubview:routeGuideMenu];

}

-(void) hideRouteGuideMenu
{
    if (isShowRouteGuideMenu)
    {
        routeGuideMenu.hidden = true;
        isShowRouteGuideMenu = false;
    }
}

-(void) initSelf
{
    isShowRouteGuideMenu    = FALSE;
    _isShowKeyboard         = FALSE;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(IBAction) pressAutoButton:(id)sender
{
    if (false == self.guideRouteUIView.isAutoSimulatorLocationUpdateStarted)
    {
        [self.autoButton setTitle:@"Stop" forState:UIControlStateNormal];
        [LocationManager setLocationUpdateType:kLocationManagerLocationUpdateType_ManualRoute];
        [LocationManager startLocationSimulation];
    }
    else
    {
        [self.autoButton setTitle:@"Auto" forState:UIControlStateNormal];
        [LocationManager setLocationUpdateType:kLocationManagerLocationUpdateType_ManualRoute];
        [LocationManager stopLocationSimulation];
    }
}

-(IBAction) pressStepButton:(id)sender
{
    [LocationManager stopLocationSimulation];
    [LocationManager triggerLocationUpdate];
    
}

-(IBAction) pressLogoButton:(id) sender
{
    [self hideRouteGuideMenu];
    [self dismissModalViewControllerAnimated:true];
}

-(IBAction) pressHUDButton:(id) sender
{
    [self hideRouteGuideMenu];
    [self.guideRouteUIView setHUD];
}

-(IBAction) pressSettingButton:(id) sender
{
    [self hideRouteGuideMenu];    
}

-(IBAction) beginShowKeyboard:(id)sender
{
    _isShowKeyboard = TRUE;
}

-(void) startRouteNavigationFrom:(Place*) startPlace To:(Place*) endPlace
{
    self.startPlace = startPlace;
    self.endPlace   = endPlace;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addRouteGuideMenu];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (YES == [SystemConfig getBOOLValue:CONFIG_IS_DEBUG])
    {
        [LocationManager startLocationTracking];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [self.guideRouteUIView startRouteNavigationFrom:self.startPlace To:self.endPlace];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    if (YES == [SystemConfig getBOOLValue:CONFIG_IS_DEBUG])
    {
        [LocationManager stopLocationTracking];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (IBAction)updateButtonClick:(id)sender
{
    

}

- (void)handleNotification:(NSNotification*)note
{
    
}

-(void) showRouteGuideMenu
{
    if (!isShowRouteGuideMenu)
    {
        routeGuideMenu.hidden = false;
        isShowRouteGuideMenu = true;
        [self updateColorFromConfig];
    }
}

- (IBAction)tagAction:(id)sender
{

    if (YES == _isShowKeyboard)
    {
        _isShowKeyboard = NO;
        [redTextField resignFirstResponder];
        [greenTextField resignFirstResponder];
        [blueTextField resignFirstResponder];
        [alphaTextField resignFirstResponder];
        [self updateColorFromUI];
        
        return;
    }
    
    if (isShowRouteGuideMenu)
    {
        [self hideRouteGuideMenu];
    }
    else
    {
        [self showRouteGuideMenu];
    }
}

- (void)viewDidUnload {
    [self setAutoButton:nil];
    [self setGuideRouteUIView:nil];
    [super viewDidUnload];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) updateColorFromUI
{
    float red, green, blue, alpha;
    
    red     = [redTextField.text floatValue]/255.0;
    green   = [greenTextField.text floatValue]/255.0;
    blue    = [blueTextField.text floatValue]/255.0;
    alpha   = [alphaTextField.text floatValue]/255.0;

    mlogDebug(@"rgb %.2f, %.2f %.2f, alpha:%.2f\n", red, green, blue, alpha);
    
    SystemConfig.defaultColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    colorPanel.backgroundColor = SystemConfig.defaultColor;
    self.guideRouteUIView.color = SystemConfig.defaultColor;
}

-(void) updateColorFromConfig
{
    int numComponents = CGColorGetNumberOfComponents([SystemConfig.defaultColor CGColor]);
    
    if (numComponents == 4)
    {
        const CGFloat *components = CGColorGetComponents([SystemConfig.defaultColor CGColor]);
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        CGFloat alpha = components[3];
        
        redTextField.text   = [NSString stringWithFormat:@"%.0f", red*255];
        greenTextField.text = [NSString stringWithFormat:@"%.0f", green*255];
        blueTextField.text  = [NSString stringWithFormat:@"%.0f", blue*255];
        alphaTextField.text = [NSString stringWithFormat:@"%.0f", alpha*255];
        
        colorPanel.backgroundColor = SystemConfig.defaultColor;
    }
}
@end
