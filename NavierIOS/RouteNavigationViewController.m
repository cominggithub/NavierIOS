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
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(IBAction) pressAutoButton:(id)sender
{
    GuideRouteUIView* view = (GuideRouteUIView*)[self view];
    if (false == view.isAutoSimulatorLocationUpdateStarted)
    {
        [self.autoButton setTitle:@"Stop" forState:UIControlStateNormal];
        [view autoSimulatorLocationUpdateStart];

    }
    else
    {
        [self.autoButton setTitle:@"Auto" forState:UIControlStateNormal];
        [view autoSimulatorLocationUpdateStop];

    }
}

-(IBAction) pressStepButton:(id)sender
{
    GuideRouteUIView* view = (GuideRouteUIView*)[self view];
    [view autoSimulatorLocationUpdateStop];
    [view triggerLocationUpdate];
}

-(void) startRouteNavigationFrom:(Place*) startPlace To:(Place*) endPlace
{
    GuideRouteUIView* view = (GuideRouteUIView*)[self view];
    [view startRouteNavigationFrom:startPlace To:endPlace];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

}

- (void)viewDidUnload {
    [self setAutoButton:nil];
    [super viewDidUnload];
}
@end
