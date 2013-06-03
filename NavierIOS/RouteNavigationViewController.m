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

-(void) startRouteNavigationFrom:(Place*) startPlace To:(Place*) endPlace
{
    GuideRouteUIView* view = (GuideRouteUIView*)[self view];
    [view startRouteNavigationFrom:startPlace To:endPlace];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationSimulator = [[LocationSimulator alloc] init];
    locationSimulator.timeInterval = 1;
    locationSimulator.locationPoints = [[NaviQueryManager getRoute] getRoutePolyLineCLLocationCoordinate2D];
    //    locationSimulator.delegate = (GuideRouteUIView*)self.view;
    //    [locationSimulator start];
    
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#if 0
// orientation for ios6
- (BOOL) shouldAutorotate
{
    
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    
    return UIInterfaceOrientationLandscapeLeft;
}
// end of orientation for ios 6
#endif

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (IBAction)updateButtonClick:(id)sender {
    
    GuideRouteUIView* view = (GuideRouteUIView*)[self view];
    locationSimulator.delegate = view;
    [locationSimulator start];
}

- (void)handleNotification:(NSNotification*)note
{
    
}

- (IBAction)tagAction:(id)sender
{
    GuideRouteUIView* view = (GuideRouteUIView*)[self view];
    [view locationUpdate:locationSimulator.getNextLocation];
}

@end
