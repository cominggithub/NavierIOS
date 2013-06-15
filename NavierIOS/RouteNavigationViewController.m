//
//  RouteNavigationViewController.m
//  NavierIOS
//
//  Created by Coming on 13/6/3.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "RouteNavigationViewController.h"

@interface RouteNavigationViewController ()

@end

@implementation RouteNavigationViewController

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
    logfn();
    logo(self.guideRouteUIView);
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
    logfn();
    logo(self.guideRouteUIView);
    [self.guideRouteUIView autoSimulatorLocationUpdateStop];
    [self.guideRouteUIView triggerLocationUpdate];
}

-(void) startRouteNavigationFrom:(Place*) startPlace To:(Place*) endPlace
{

    logfn();
    logo(self.guideRouteUIView);
    [self.guideRouteUIView startRouteNavigationFrom:startPlace To:endPlace];
    logfn();
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    logfn();
    logo(self.guideRouteUIView);
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

- (IBAction)tagAction:(id)sender
{
    logfn();
}

- (void)viewDidUnload {
    [self setAutoButton:nil];
    [self setGuideRouteUIView:nil];
    [super viewDidUnload];
}
@end
