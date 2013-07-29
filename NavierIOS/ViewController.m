//
//  ViewController.m
//  NavierIOS
//
//  Created by Coming on 13/2/25.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "ViewController.h"
#import "RouteNavigationViewController.h"
#import "CarPanel1ViewController.h"


#define FILE_DEBUG FALSE
#include <NaviUtil/Log.h>

@interface ViewController ()

@end

@implementation ViewController
{
    RouteNavigationViewController *routeNavigationViewController;
    ADBannerView *adView;
}



-(BOOL) bannerIsVisible
{
    return TRUE == ([SystemConfig getBOOLValue:CONFIG_IS_AD] && _bannerIsVisible);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addBanner:self.contentView];
    
    self.selectPlaceTableView.backgroundColor = [UIColor clearColor];
    self.selectPlaceTableView.opaque = NO;
    self.selectPlaceTableView.backgroundView = nil;
    
    routeNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass
                                 ([RouteNavigationViewController class])];
    [LocationManager startMonitorLocation];
    
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
}

- (IBAction)pressRoute:(id)sender
{
//    CLLocationCoordinate2D ncku     = CLLocationCoordinate2DMake(22.996501,120.216678);
//    CLLocationCoordinate2D accton   = CLLocationCoordinate2DMake(23.099313,120.284371);
    
    CLLocationCoordinate2D yufon = CLLocationCoordinate2DMake(22.987968, 120.227315);
    CLLocationCoordinate2D ampin = CLLocationCoordinate2DMake(22.994664, 120.142965);
    
    [NaviQueryManager planRouteStartLocation:yufon EndLocation:ampin];
//     [NaviQueryManager planRouteStartLocationText:@"高雄" EndLocationText:@"花蓮"];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:PLAN_ROUTE_DONE object:nil];
}

- (IBAction)pressTextRoute:(id)sender
{
    [NaviQueryManager planRouteStartLocationText:@"成大" EndLocationText:@"台南一中"];
}

- (IBAction)pressCarPanel:(id)sender
{
    // Get the storyboard named secondStoryBoard from the main bundle:
    UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"CarPanels" bundle:nil];
    UIViewController *carPanel = [secondStoryBoard instantiateInitialViewController];
    //
    // **OR**
    //
    // Load the view controller with the identifier string myTabBar
    // Change UIViewController to the appropriate class
//    UIViewController *carPanel = (UIViewController *)[secondStoryBoard instantiateViewControllerWithIdentifier:@"CarPanel"];
    
    // Then push the new view controller in the usual way:
//    [self.navigationController pushViewController:carPanel animated:YES];
    
    [self presentModalViewController:carPanel animated:TRUE];
    
}

- (void)viewDidUnload {

    [self setSelectPlaceTableView:nil];
    [self setContentView:nil];
    [self setCarPanel_outer_circle:nil];
    [self setCarPanel_inner_circle:nil];
    [LocationManager stopMonitorLocation];
    [super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.selectPlaceTableView reloadData];
}

-(void) viewDidAppear:(BOOL)animated
{
    [self.carPanel_outer_circle setImageTintColor:[UIColor whiteColor]];
    [self.carPanel_inner_circle setImageTintColor:[UIColor whiteColor]];
    [UIAnimation runSpinAnimationOnView:self.carPanel_outer_circle duration:100 rotations:0.01 repeat:100];

    [UIAnimation runSpinAnimationOnView:self.carPanel_inner_circle duration:100 rotations:0.1 repeat:100];
    
    [self showAdAnimated:NO];
}

#pragma mark - Table view delegate
/* for UITableView */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [User getPlaceCountBySectionMode: kSectionMode_Home_Office_Favor_SearchedText section:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Place* place;
    UILabel *nameLabel;
    UITableViewCell *cell;
    
    cell                = [self.selectPlaceTableView dequeueReusableCellWithIdentifier:@"SelectPlaceCell"];
    place               = [User getPlaceBySectionMode:kSectionMode_Home_Office_Favor_SearchedText
                                              section:indexPath.section
                                                index:indexPath.row];
    if (nil != place)
    {
        nameLabel           = (UILabel*)[cell viewWithTag:3];
        nameLabel.text      = place.name;
//        [nameLabel autoFontSize:16 maxWidth:280];
    }

    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    Place* routeStartPlace;
    Place* routeEndPlace;
    
    routeStartPlace = [LocationManager currentPlace];
    
    routeEndPlace = [User getPlaceBySectionMode:kSectionMode_Home_Office_Favor_SearchedText
                                        section:indexPath.section
                                           index:indexPath.row];
    
    if (nil != routeStartPlace && nil != routeEndPlace && ![routeStartPlace isCoordinateEqualTo:routeEndPlace])
    {
        [self presentModalViewController:routeNavigationViewController animated:YES];
        [routeNavigationViewController startRouteNavigationFrom:routeStartPlace To:routeEndPlace];
    }

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return [SystemManager getLanguageString:@"Home"];
        case 1:
            return [SystemManager getLanguageString:@"Office"];
        case 2:
            return [SystemManager getLanguageString:@"Favor"];
    }
    
    return @"";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 8, 320, 12);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:14];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;

}

#pragma mark - Banner

-(void) addBanner:(UIView*) contentView
{
    if (FALSE == [SystemConfig getBOOLValue:CONFIG_IS_AD])
        return;
    
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)])
    {
        adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else
    {
        adView = [[ADBannerView alloc] init];
    }
    
    //    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    adView.requiredContentSizeIdentifiers   = [NSSet setWithObject:ADBannerContentSizeIdentifierLandscape];
    adView.currentContentSizeIdentifier     = ADBannerContentSizeIdentifierLandscape;
    adView.delegate     = self;
    
    [self.view addSubview:adView];
    
    [self showAdAnimated:NO];
}

- (void)showAdAnimated:(BOOL)animated
{
    if (nil == adView)
        return;
    
    CGRect contentFrame = [SystemManager lanscapeScreenRect];
    
    CGRect bannerFrame = adView.frame;
    
    if (adView.bannerLoaded)
    {
        contentFrame.size.height    -= adView.frame.size.height;
        contentFrame.origin.y       = adView.frame.size.height;
        bannerFrame.origin.y        = 0;
    } else
    {
        bannerFrame.origin.y = -adView.frame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        _contentView.frame = contentFrame;
        [_contentView layoutIfNeeded];
        adView.frame = bannerFrame;
    }];
   
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        self.bannerIsVisible = YES;
        [self showAdAnimated:YES];

    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{

    if (self.bannerIsVisible)
    {
        self.bannerIsVisible = NO;
        [self showAdAnimated:YES];
    }
}


- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    BOOL shouldExecuteAction = true; // your application implements this method
    
    if (!willLeave && shouldExecuteAction)
    {
        // insert code here to suspend any services that might conflict with the advertisement
    }
    
    return shouldExecuteAction;
    
    return false;
}



- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{

}



@end
