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
    
    UITextField *rgbHexCodeTextField;
    UIView *colorPanel;
    int routeTextIndex;
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
   
    rgbHexCodeTextField    = (UITextField *)[routeGuideMenu viewWithTag:101];

    colorPanel  = (UIView *)[routeGuideMenu viewWithTag:105];
    
    rgbHexCodeTextField.delegate       = self;

    [rgbHexCodeTextField addTarget:self
                     action:@selector(beginShowKeyboard:)
           forControlEvents:UIControlEventEditingDidBegin];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateColorFromUI)
     name:UITextFieldTextDidChangeNotification
     object:rgbHexCodeTextField];
    
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
        routeGuideMenu.hidden   = TRUE;
        isShowRouteGuideMenu    = FALSE;
    }
}

-(void) initSelf
{
    isShowRouteGuideMenu    = FALSE;
    _isShowKeyboard         = FALSE;
    routeTextIndex          = 0;
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
    [self dismissViewControllerAnimated:true completion:nil];
}

-(IBAction) pressHUDButton:(id) sender
{
    [self hideRouteGuideMenu];
    self.guideRouteUIView.isHud = !self.guideRouteUIView.isHud;
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
    mlogAssertNotNil(startPlace);
    mlogAssertNotNil(endPlace);
    
    self.startPlace = startPlace;
    self.endPlace   = endPlace;

    [User addRecentPlace:self.endPlace];
    [User save];
    [self.guideRouteUIView startRouteNavigationFrom:self.startPlace To:self.endPlace];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initSelf];
    [self addRouteGuideMenu];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [self active];
}

-(void) viewDidAppear:(BOOL)animated
{
 
}

-(void) viewWillDisappear:(BOOL)animated
{
 
    [self inactive];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
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
        [rgbHexCodeTextField resignFirstResponder];

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
    [self setStepButton:nil];
    [self setTextButton:nil];

    [super viewDidUnload];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self updateColorFromUI];
    [textField resignFirstResponder];
    return YES;
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    if ([notification object] == rgbHexCodeTextField)
    {
        [self updateColorFromUI];
    }
}

-(void) updateColorFromUI
{
    UIColor *newColor;
    
    newColor = [UIColor colorWithRGBHexCode:rgbHexCodeTextField.text];
    
    if (nil != newColor)
    {
        [SystemConfig setValue:CONFIG_RN1_COLOR uicolor:newColor];
        colorPanel.backgroundColor      = [SystemConfig getUIColorValue:CONFIG_RN1_COLOR];
        self.guideRouteUIView.color     = [SystemConfig getUIColorValue:CONFIG_RN1_COLOR];
    }
}

-(void) updateColorFromConfig
{
    UIColor* color;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;

    color = [SystemConfig getUIColorValue:CONFIG_RN1_COLOR];
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    rgbHexCodeTextField.text = [color getRGBHexCode];
    colorPanel.backgroundColor = [SystemConfig getUIColorValue:CONFIG_RN1_COLOR];
 
}
- (IBAction)pressTextButton:(id)sender
{
    self.guideRouteUIView.messageBoxText = [SystemManager getLanguageString:[NSString stringWithFormat:@"routeGuideText%d", routeTextIndex++]];
    routeTextIndex = routeTextIndex%10;
    
    if (routeTextIndex == 0)
        self.guideRouteUIView.messageBoxText = @"";
}

-(void) active
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.guideRouteUIView.color = [SystemConfig getUIColorValue:CONFIG_RN1_COLOR];
    
    if (YES == [SystemConfig getBoolValue:CONFIG_IS_DEBUG])
    {
        self.textButton.hidden = NO;
        self.autoButton.hidden = NO;
        self.stepButton.hidden = NO;
        
        [LocationManager startLocationTracking];
    }
    else
    {
        self.textButton.hidden = YES;
        self.autoButton.hidden = YES;
        self.stepButton.hidden = YES;
    }
    
    [self.guideRouteUIView active];
    
    if (YES == [SystemConfig getBoolValue:CONFIG_IS_DEBUG])
    {
        [LocationManager startLocationTracking];
    }
    
    if (YES == [SystemConfig getBoolValue:CONFIG_IS_LOCATION_SIMULATOR])
    {
        [LocationManager stopMonitorLocation];
    }
    else
    {
        [LocationManager startMonitorLocation];
    }
    
}

-(void) inactive
{
    [self.guideRouteUIView inactive];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if (YES == [SystemConfig getBoolValue:CONFIG_IS_DEBUG])
    {
        [LocationManager stopLocationTracking];
    }
    [LocationManager stopMonitorLocation];
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
