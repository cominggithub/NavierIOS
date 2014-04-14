//
//  RouteNavigationViewController.m
//  NavierIOS
//
//  Created by Coming on 13/6/3.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "RouteNavigationViewController.h"
#import "BuyUIViewController.h"

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
    
    /* CarPanel1MenuView */
    CarPanel1MenuView *carPanelMenuView;
    BuyUIViewController *buyViewController;
}

-(void) initSelf
{
    isShowRouteGuideMenu    = FALSE;
    _isShowKeyboard         = FALSE;
    routeTextIndex          = 0;
    buyViewController   = (BuyUIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass ([BuyUIViewController class])];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initSelf];
    //    [self addRouteGuideMenu];
    [self addCarPanelMenu];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self checkIapItem];
    [self active];
}

-(void) viewDidAppear:(BOOL)animated
{

}

-(void) viewDidDisappear:(BOOL)animated
{
    [[UIScreen mainScreen] setBrightness:[SysConfig getFloatValue:CONFIG_DEFAULT_BRIGHTNESS]];
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

#if 0
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}
#endif

- (void)viewDidUnload {
    
    
    [self setAutoButton:nil];
    [self setGuideRouteUIView:nil];
    [self setStepButton:nil];
    [self setTextButton:nil];
    
    [super viewDidUnload];
}

#pragma mark -- property

-(void) setIsHud:(BOOL)isHud
{
    _isHud = isHud;
    
    if(self.isHud == TRUE)
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
    self.guideRouteUIView.color = self.color;
    
}

-(void) setIsSpeedUnitMph:(BOOL)isSpeedUnitMph
{
    _isSpeedUnitMph                         = isSpeedUnitMph;
    self.guideRouteUIView.isSpeedUnitMph    = self.isSpeedUnitMph;

}

#pragma mark -- UI

-(IBAction) pressAutoButton:(id)sender
{
    if ([self.autoButton.titleLabel.text isEqualToString:@"Auto"])
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

- (IBAction)pressTextButton:(id)sender
{
    self.guideRouteUIView.messageBoxText = [SystemManager getLanguageString:[NSString stringWithFormat:@"routeGuideText%d", routeTextIndex++]];
    routeTextIndex = routeTextIndex%10;
    
    if (routeTextIndex == 0)
        self.guideRouteUIView.messageBoxText = @"";
}

- (IBAction)pressContentViewButton:(id)sender
{
    carPanelMenuView.hidden = !carPanelMenuView.hidden;
}

-(IBAction) beginShowKeyboard:(id)sender
{
    _isShowKeyboard = TRUE;
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


#pragma mark -- operation

-(void) startRouteNavigationFrom:(Place*) startPlace To:(Place*) endPlace
{
    mlogAssertNotNil(startPlace);
    mlogAssertNotNil(endPlace);
    
    self.startPlace = startPlace;
    self.endPlace   = endPlace;

    if (kPlaceType_CurrentPlace != self.endPlace.placeType)
    {
        [User addRecentPlace:self.endPlace];
        [User save];
        [self.guideRouteUIView startRouteNavigationFrom:self.startPlace To:self.endPlace];
    }
    
}

- (void)checkIapItem
{
    carPanelMenuView.lockColorSelection = ![SysConfig getBoolValue:CONFIG_IAP_IS_ADVANCED_VERSION];
}


-(void) updateColorFromUI
{
    UIColor *newColor;
    
    newColor = [UIColor colorWithRGBHexCode:rgbHexCodeTextField.text];
    
    if (nil != newColor)
    {
        [SysConfig setValue:CONFIG_RN1_COLOR uicolor:newColor];
        colorPanel.backgroundColor      = [SysConfig getUIColorValue:CONFIG_RN1_COLOR];
        self.guideRouteUIView.color     = [SysConfig getUIColorValue:CONFIG_RN1_COLOR];
    }
}

-(void) updateColorFromConfig
{
    UIColor* color;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;

    color = [SysConfig getUIColorValue:CONFIG_RN1_COLOR];
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    rgbHexCodeTextField.text = [color getRGBHexCode];
    colorPanel.backgroundColor = [SysConfig getUIColorValue:CONFIG_RN1_COLOR];
 
}


-(void) active
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.isHud          = [SysConfig getBoolValue:CONFIG_RN1_IS_HUD];
    self.color          = [SysConfig getUIColorValue:CONFIG_RN1_COLOR];
    self.isSpeedUnitMph = [SysConfig getBoolValue:CONFIG_RN1_IS_SPEED_UNIT_MPH];

    
    if (YES == [SysConfig getBoolValue:CONFIG_H_IS_DEBUG])
    {
        self.textButton.hidden = NO;
        self.autoButton.hidden = NO;
        self.stepButton.hidden = NO;
    }
    else
    {
        self.textButton.hidden = YES;
        self.autoButton.hidden = YES;
        self.stepButton.hidden = YES;
    }
    
    [self.guideRouteUIView active];
    
    if (YES == [SysConfig getBoolValue:CONFIG_H_IS_DEBUG])
    {
        [LocationManager startLocationTracking];
    }
    
    if (YES == [SysConfig getBoolValue:CONFIG_H_IS_LOCATION_SIMULATOR])
    {
        [LocationManager stopMonitorLocation];
    }
    else
    {
        [LocationManager startMonitorLocation];
    }
 
    if (YES == [SysConfig getBoolValue:CONFIG_IS_TRACK_LOCATION])
    {
        [LocationManager startLocationTracking];
    }
    
    [[UIScreen mainScreen] setBrightness:1.0];
    
    carPanelMenuView.hidden = YES;
}

-(void) inactive
{
    [self.guideRouteUIView inactive];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if (YES == [SysConfig getBoolValue:CONFIG_H_IS_DEBUG])
    {
        [LocationManager stopLocationTracking];
    }

    [[UIScreen mainScreen] setBrightness:[SysConfig getFloatValue:CONFIG_DEFAULT_BRIGHTNESS]];
    [LocationManager stopMonitorLocation];
    carPanelMenuView.hidden = YES;
    
    [self.autoButton setTitle:@"Auto" forState:UIControlStateNormal];
    [LocationManager setLocationUpdateType:kLocationManagerLocationUpdateType_ManualRoute];
    if (YES == [SysConfig getBoolValue:CONFIG_H_IS_LOCATION_SIMULATOR])
    {
        if (NO == [SysConfig getBoolValue:CONFIG_H_IS_SIMULATE_CAR_MOVEMENT])
        {
            [LocationManager stopLocationSimulation];
        }
    }
    [LocationManager stopLocationTracking];
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -- CarPanel1MenuView

-(void) addCarPanelMenu
{
    NSArray *xibContents                = [[NSBundle mainBundle] loadNibNamed:@"CarPanel1MenuView" owner:self options:nil];
    carPanelMenuView                    = [xibContents lastObject];
    carPanelMenuView.accessibilityLabel = @"carPanel1MenuView";
    carPanelMenuView.delegate           = self;
    
    carPanelMenuView.isHud              = [SysConfig getBoolValue:CONFIG_RN1_IS_HUD];
    carPanelMenuView.isSpeedUnitMph     = [SysConfig getBoolValue:CONFIG_RN1_IS_SPEED_UNIT_MPH];
    carPanelMenuView.panelColor         = [SysConfig getUIColorValue:CONFIG_RN1_COLOR];
    
    [self.view addSubview:carPanelMenuView];
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

-(void) showRouteGuideMenu
{
    if (!isShowRouteGuideMenu)
    {
        routeGuideMenu.hidden = false;
        isShowRouteGuideMenu = true;
        [self updateColorFromConfig];
    }
}

#pragma mark -- delegate

-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm changeColor:(UIColor*) color
{
    [SysConfig setValue:CONFIG_RN1_COLOR uicolor:color];
    self.color = [SysConfig getUIColorValue:CONFIG_RN1_COLOR];
}

-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm changeHud:(BOOL) isHud
{
    [SysConfig setValue:CONFIG_RN1_IS_HUD BOOL:isHud];
    self.isHud = [SysConfig getBoolValue:CONFIG_RN1_IS_HUD];
}

-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm changeSpeedUnit:(BOOL) isMph
{
    [SysConfig setValue:CONFIG_RN1_IS_SPEED_UNIT_MPH BOOL:isMph];
    self.isSpeedUnitMph = [SysConfig getBoolValue:CONFIG_RN1_IS_SPEED_UNIT_MPH];
}

-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm pressLogoButton:(BOOL) isPressed
{
    if (YES == isPressed)
    {
        carPanelMenuView.hidden = YES;
        [LocationManager stopLocationSimulation];
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
    if (YES == isPressed && NavierHUDIAPHelper.iapItemCount > 0)
    {
        [self presentViewController:buyViewController animated:YES completion:nil];
    }
    carPanelMenuView.hidden = YES;
}


- (IBAction)tagAction:(id)sender
{
    UITapGestureRecognizer* tapRecognizer;
    if (YES == _isShowKeyboard)
    {
        _isShowKeyboard = NO;
        [rgbHexCodeTextField resignFirstResponder];
        
        [self updateColorFromUI];
        
        return;
    }

    tapRecognizer = (UITapGestureRecognizer*)sender;

    if (!CGRectContainsPoint(carPanelMenuView.bounds, [tapRecognizer locationInView:carPanelMenuView]))
    {
        carPanelMenuView.hidden = !carPanelMenuView.hidden;
    }
    else if (carPanelMenuView.hidden)
        carPanelMenuView.hidden = NO;
}


@end
