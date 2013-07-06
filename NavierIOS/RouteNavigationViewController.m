//
//  RouteNavigationViewController.m
//  NavierIOS
//
//  Created by Coming on 13/6/3.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "RouteNavigationViewController.h"

#define FILE_DEBUG FALSE
#include <NaviUtil/Log.h>

@interface RouteNavigationViewController ()

@end

@implementation RouteNavigationViewController
{
    bool isShowRouteGuideMenu;
    int routeGuideMenuOffset;
    UIView *routeGuideMenu;
    
    UIButton *routeGuideMenuLogoButton;
    UIButton *routeGuideMenuHUDButton;
    UIButton *routeGuideMenuSettingButton;
    
}

-(void) addRouteGuideMenu
{
    UIView *subView;
    isShowRouteGuideMenu = false;
    
    NSArray *xibContents = [[NSBundle mainBundle] loadNibNamed:@"RouteGuideMenu" owner:self options:nil];
    
    CGRect frame;

    routeGuideMenu = [xibContents lastObject];
    
    routeGuideMenuOffset = 100;
    
    logfns("RouteGuideMenu: frame: (%.0f, %.0f) (%.0f, %.0f), bounds: (%.0f, %.0f) (%.0f, %.0f)\n",
           routeGuideMenu.frame.origin.x,
           routeGuideMenu.frame.origin.y,
           routeGuideMenu.frame.size.width,
           routeGuideMenu.frame.size.height,
           routeGuideMenu.bounds.origin.x,
           routeGuideMenu.bounds.origin.y,
           routeGuideMenu.bounds.size.width,
           routeGuideMenu.bounds.size.height
           );
    
    
//    routeGuideMenu.frame = frame;
//    subView = [xibContents lastObject];

    logfns("RouteGuideMenu: frame: (%.0f, %.0f) (%.0f, %.0f), bounds: (%.0f, %.0f) (%.0f, %.0f)\n",
           routeGuideMenu.frame.origin.x,
           routeGuideMenu.frame.origin.y,
           routeGuideMenu.frame.size.width,
           routeGuideMenu.frame.size.height,
           routeGuideMenu.bounds.origin.x,
           routeGuideMenu.bounds.origin.y,
           routeGuideMenu.bounds.size.width,
           routeGuideMenu.bounds.size.height
           );

//    routeGuideMenu = [subView.subviews lastObject];
    


    routeGuideMenuLogoButton        = (UIButton *)[routeGuideMenu viewWithTag:1];
    routeGuideMenuHUDButton         = (UIButton *)[routeGuideMenu viewWithTag:2];
    routeGuideMenuSettingButton     = (UIButton *)[routeGuideMenu viewWithTag:3];

    logo(routeGuideMenuLogoButton);
    
    [routeGuideMenuLogoButton addTarget:self
                               action:@selector(pressLogoButton:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [routeGuideMenuHUDButton addTarget:self
                             action:@selector(pressHUDButton:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [routeGuideMenuSettingButton addTarget:self
                                 action:@selector(pressSettingButton:)
                       forControlEvents:UIControlEventTouchUpInside];
   
    [routeGuideMenu setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    routeGuideMenu.hidden = true;
    [self.view addSubview:routeGuideMenu];
  
    routeGuideMenu.layer.borderColor    = [UIColor whiteColor].CGColor;
    routeGuideMenu.layer.borderWidth    = 3.0f;
    routeGuideMenu.layer.cornerRadius   = 10;
    routeGuideMenu.layer.masksToBounds  = YES;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(routeGuideMenu);
    UIView *contentView = self.view;

    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"[routeGuideMenu(277)]"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[routeGuideMenu(127)]"
                                             options:NSLayoutFormatAlignAllCenterY
                                             metrics:nil
                                               views:views]];
#if 0

    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[routeGuideMenu]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[routeGuideMenu]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
#endif


    
    
//    [_window visualizeConstraints:[contentView constraints]];
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
    isShowRouteGuideMenu = false;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    logfn();
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        logo(self.guideRouteUIView);
    }
    return self;
}

-(IBAction) pressAutoButton:(id)sender
{


    if (false == self.guideRouteUIView.isAutoSimulatorLocationUpdateStarted)
    {
        [self.autoButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self.guideRouteUIView autoSimulatorLocationUpdateStart];

    }
    else
    {
        [self.autoButton setTitle:@"Auto" forState:UIControlStateNormal];
        [self.guideRouteUIView autoSimulatorLocationUpdateStop];

    }
}

-(IBAction) pressStepButton:(id)sender
{
    [self.guideRouteUIView autoSimulatorLocationUpdateStop];
    [self.guideRouteUIView triggerLocationUpdate];
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

-(void) startRouteNavigationFrom:(Place*) startPlace To:(Place*) endPlace
{

    [self.guideRouteUIView startRouteNavigationFrom:startPlace To:endPlace];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addRouteGuideMenu];
    //    locationSimulator.delegate = (GuideRouteUIView*)self.view;
    //    [locationSimulator start];
    
	// Do any additional setup after loading the view.
    
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
    }
}

- (IBAction)tagAction:(id)sender
{
    
    logfns("RouteGuideMenu: frame: (%.0f, %.0f) (%.0f, %.0f), bounds: (%.0f, %.0f) (%.0f, %.0f)\n",
           routeGuideMenu.frame.origin.x,
           routeGuideMenu.frame.origin.y,
           routeGuideMenu.frame.size.width,
           routeGuideMenu.frame.size.height,
           routeGuideMenu.bounds.origin.x,
           routeGuideMenu.bounds.origin.y,
           routeGuideMenu.bounds.size.width,
           routeGuideMenu.bounds.size.height
           );
    
    logfn();
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
@end
