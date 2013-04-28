//
//  ViewController.m
//  NavierIOS
//
//  Created by Coming on 13/2/25.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Custom initialization

//    locationManager.delegate = self;
    
	// Do any additional setup after loading the view, typically from a nib.

/* disable banner */
#if 0
    ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierLandscape];
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    adView.delegate = self;
    [self.view addSubview:adView];
#endif

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* for orientation in iOS 5.0, 5.1 
 * must set it for evern UIViewController?
 */
 
 
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (IBAction)pressPlace:(id)sender
{
    int i;
    NSString *fileName = @"/Users/Coming/ios/google/place_tainan1_senior.json";
    NSArray* places = [NSArray arrayWithArray:[Place parseJson:fileName]];
    
    for(i=0; i<places.count; i++)
    {
        printf("%s\n", [[[places objectAtIndex:i] description] UTF8String]);
    }

    
    // This function can be called with any number (even 0) or type of objects, as long as you terminate it with "nil":
    mlogWarning(NONE, @"foo", [NSNumber numberWithInt:4], @"bar", nil);
    mlogInfo(NONE, @"foo", [NSNumber numberWithInt:4], @"bar", nil);
    mlogDebug(NONE, @"foo", [NSNumber numberWithInt:4], @"bar", nil);
    mlogError(NONE, @"foo", [NSNumber numberWithInt:4], @"bar", nil);
    
}

- (IBAction)pressRoute:(id)sender
{
    CLLocationCoordinate2D ncku     = CLLocationCoordinate2DMake(22.996501,120.216678);
    CLLocationCoordinate2D accton   = CLLocationCoordinate2DMake(23.099313,120.284371);
    
//    [NaviQueryManager planRouteStartLocation:ncku EndLocation:accton];
      [NaviQueryManager planRouteStartLocationText:@"高雄" EndLocationText:@"花蓮"];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:PLAN_ROUTE_DONE object:nil];
}

- (IBAction)pressTextRoute:(id)sender
{
    [NaviQueryManager planRouteStartLocationText:@"成大" EndLocationText:@"台南一中"];
}

- (IBAction)pressNaviHUD:(id)sender {
}
- (void)viewDidUnload {

    [super viewDidUnload];
}

#if 0
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    logo(error.description);
    if (self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}


- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"Banner view is beginning an ad action");
    BOOL shouldExecuteAction = [self allowActionToRun]; // your application implements this method
    if (!willLeave && shouldExecuteAction)
    {
        // insert code here to suspend any services that might conflict with the advertisement
    }
    return shouldExecuteAction;
    
    return false;
}


- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    logfn();
}

#endif
@end
