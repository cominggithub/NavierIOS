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
#import <AVFoundation/AVFoundation.h>


#define FILE_DEBUG FALSE
#include <NaviUtil/Log.h>

@interface ViewController ()

@end

@implementation ViewController
{
    RouteNavigationViewController *routeNavigationViewController;
    ADBannerView *adView;
    
    /* bug: bounds don't change to landscape mode */
    CGRect oriProtraitMapButtonFrame;
    CGRect oriProtraitCarPanelViewFrame;
    CGRect oriLandscapeMapButtonFrame;
    CGRect oriLandscapeCarPanelViewFrame;
    UIViewAutoresizing oriMapButtonAutoresizingMask;
    UIViewAutoresizing oriCarPanelViewAutoresizingMask;
    SectionMode sectionMode;
    NSMutableArray* placeIcons;
    AVAudioPlayer *audioPlayer;
}

- (void)viewDidLoad
{
    CGFloat xoffset;
    [super viewDidLoad];
    
    [self addBanner:self.contentView];
    
    routeNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass
                                 ([RouteNavigationViewController class])];

    oriProtraitMapButtonFrame       = self.mapButton.frame;
    oriLandscapeMapButtonFrame      = self.mapButton.frame;
    oriMapButtonAutoresizingMask    = self.mapButton.autoresizingMask;

    
    xoffset = self.view.bounds.size.width > self.view.bounds.size.height ? 0 : self.view.bounds.size.height - self.view.bounds.size.width;
    
    oriLandscapeMapButtonFrame.origin.x      += xoffset;
    oriLandscapeCarPanelViewFrame.origin.x   += xoffset;

    sectionMode = kSectionMode_Home_Office_Favor_Searched;
    
    placeIcons = [[NSMutableArray alloc] initWithCapacity:kPlaceType_Max];
    
    [placeIcons insertObject:[UIImage imageNamed:@"search34"] atIndex:kPlaceType_None];
    [placeIcons insertObject:[UIImage imageNamed:@"home34"] atIndex:kPlaceType_Home];
    [placeIcons insertObject:[UIImage imageNamed:@"office34"] atIndex:kPlaceType_Office];
    [placeIcons insertObject:[UIImage imageNamed:@"favor34"] atIndex:kPlaceType_Favor];
    [placeIcons insertObject:[UIImage imageNamed:@"search34"] atIndex:kPlaceType_SearchedPlace];
    [placeIcons insertObject:[UIImage imageNamed:@"search34"] atIndex:kPlaceType_SearchedPlaceText];
    [placeIcons insertObject:[UIImage imageNamed:@"search34"] atIndex:kPlaceType_CurrentPlace];
    
    [self.mapButton setImage:[UIImage imageNamed:@"map_btn_pressed"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.mapButton setSelected:YES];

    [self.carPanelButton setImage:[UIImage imageNamed:@"speed_btn_pressed"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.carPanelButton setSelected:YES];
    
    /* init table view */
//    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_tableview"]];

//    self.tableView.backgroundView = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:IAPHelperProductUpdatedNotification
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* for orientation in iOS 5.0, 5.1 
 * must set it for evern UIViewController?
 */
 
#if 0
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}
#endif



- (void)viewDidUnload {

    [self setContentView:nil];
    [LocationManager stopMonitorLocation];
    [super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [self checkIAPItem];
#if DEBUG
    self.debugConfigButton.hidden = NO;
#else
    self.debugConfigButton.hidden = YES;
#endif
}

-(void) viewDidAppear:(BOOL)animated
{
    
    [self showAdAnimated:NO];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void) checkIAPItem
{
    if (NavierHUDIAPHelper.iapItemCount < 1)
    {
       [NavierHUDIAPHelper retrieveProduct];
        self.buyButton.hidden = YES;
    }
    else
    {
        self.buyButton.hidden = NO;
    }
    self.bannerIsVisible = [SystemConfig getBoolValue:CONFIG_IAP_IS_NO_AD] && [SystemConfig getBoolValue:CONFIG_IS_AD];
    
    self.buyButton.hidden = NO;
}

- (void) receiveNotification:(NSNotification *) notification
{
    logfn();
    if ([[notification name] isEqualToString:IAPHelperProductUpdatedNotification])
    {
        logfn();
        [self checkIAPItem];
    }
}

#if 0
-(void) showHasPlaceMode
{
    self.selectPlaceTableView.hidden            = NO;
    self.selectPlaceTableViewBackground.hidden  = NO;

    /* in landscape */
    if (self.view.bounds.size.width > self.view.bounds.size.height)
    {
        self.mapButton.frame                = oriLandscapeMapButtonFrame;
        self.carPanelView.frame             = oriLandscapeCarPanelViewFrame;
    }
    /* in protrait */
    else
    {
        self.mapButton.frame                = oriProtraitMapButtonFrame;
        self.carPanelView.frame             = oriProtraitCarPanelViewFrame;
    }

}


-(void) showHasNoPlaceMode
{

    return;
    CGRect frame;
    CGFloat margin;
    CGFloat offset;
    CGFloat viewWidth;
    CGFloat viewHeight;
    
    
    frame       = self.view.bounds;
    offset      = 100.0;
    viewWidth   = frame.size.width > frame.size.height ? frame.size.width : frame.size.height;
    viewHeight  = frame.size.width < frame.size.height ? frame.size.width : frame.size.height;
    
    /* we are in landscape mode, so translate width to height, and height to width */
    margin  = (viewWidth - self.mapButton.frame.size.width - offset - self.carPanelView.frame.size.width)/2.0;
    
    /* map button */
    frame                   = self.mapButton.frame;
    frame.origin.x          = margin;
    frame.origin.y          = (viewHeight)/2.0 - frame.size.height/2.0 + 50;
    self.mapButton.frame    = frame;
    self.mapButton.autoresizingMask = UIViewAutoresizingNone;
    
    /* car panel */
    frame                   = self.carPanelView.frame;
    frame.origin.x          = margin + self.mapButton.frame.size.width + offset;
    frame.origin.y          = (viewHeight)/2.0 - frame.size.height/2.0 + 50;
    self.carPanelView.frame = frame;
    self.carPanelView.autoresizingMask = UIViewAutoresizingNone;
    
    self.selectPlaceTableView.hidden            = YES;
    self.selectPlaceTableViewBackground.hidden  = YES;

}
#endif

#pragma mark - Table view delegate
/* for UITableView */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
//    return [User getSectionCount:sectionMode];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    return [User getPlaceCountBySectionMode: kSectionMode_Home_Office_Favor_SearchedText section:section];
    return User.recentPlaces.count > 0 ? User.recentPlaces.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Place* place;
    UILabel *nameLabel;
    UIImageView *icon;
    UITableViewCell *cell;
   
    cell        = [self.tableView dequeueReusableCellWithIdentifier:@"SelectPlaceCell"];
    nameLabel   = (UILabel*)[cell viewWithTag:3];
    icon        = (UIImageView*)[cell viewWithTag:2];
    
    if (User.recentPlaces.count > 0)
    {
        place   = [User.recentPlaces objectAtIndex:indexPath.row];
        if (nil != place)
        {
            nameLabel.text = place.name;
            icon.image     = [placeIcons objectAtIndex:place.placeType];
        }
    }
    else
    {
        CGRect frame;
        frame           = nameLabel.frame;
        nameLabel.text  = [SystemManager getLanguageString:@"There is no recent place now"];
        icon.image      = [placeIcons objectAtIndex:kPlaceType_Favor];
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

    if (User.recentPlaces.count < 1)
        return;
    
    routeStartPlace = [LocationManager currentPlace];
    routeEndPlace   = [User.recentPlaces objectAtIndex:indexPath.row];
    
    logO(routeStartPlace);
    if (nil != routeStartPlace && nil != routeEndPlace && ![routeStartPlace isCoordinateEqualTo:routeEndPlace])
    {
        [self presentViewController:routeNavigationViewController animated:YES completion:nil];
        [routeNavigationViewController startRouteNavigationFrom:routeStartPlace To:routeEndPlace];
    }

}

#if 0
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
#if 0
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
#endif
    
    UIView *view = [[UIView alloc] init];
    CGRect viewFrame = CGRectMake(0, 0, 24, 22);
    
    UIImageView *imgView;

    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.frame = viewFrame;
    
    [view addSubview:imgView];
    view.frame = viewFrame;
    
    return view;
    

}
#endif

#pragma mark - Banner

-(void) addBanner:(UIView*) contentView
{
    if (FALSE == [SystemConfig getBoolValue:CONFIG_IS_AD])
        return;
    
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)])
    {
        adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else
    {
        adView = [[ADBannerView alloc] init];
    }
    
    [adView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    adView.delegate     = self;

    [self.view addSubview:adView];
    [self showAdAnimated:NO];
}

-(void) showAdAnimated:(BOOL)animated
{
    if (nil == adView)
        return;
    
    CGRect contentFrame = [SystemManager lanscapeScreenRect];
    
    CGRect bannerFrame = adView.frame;
    
    if (adView.bannerLoaded && self.bannerIsVisible)
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
    [self showAdAnimated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self showAdAnimated:YES];
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

#pragma mark -- UI Action

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
    
    CLLocationCoordinate2D yufon = CLLocationCoordinate2DMake(22.987968, 120.227315);
    CLLocationCoordinate2D ampin = CLLocationCoordinate2DMake(22.994664, 120.142965);
    
    [NaviQueryManager planRouteStartLocation:yufon EndLocation:ampin];
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
    
    [self presentViewController:carPanel animated:TRUE completion:nil];
    
}

-(IBAction) pressTestButton:(id)sender
{
    
    NSBundle *uiKitBundle = [NSBundle bundleWithIdentifier:@"com.apple.UIKit"];
    NSString *yesText = uiKitBundle ? [uiKitBundle localizedStringForKey:@"設定" value:nil table:nil] : @"YES";
    NSString *noText = uiKitBundle ? [uiKitBundle localizedStringForKey:@"No" value:nil table:nil] : @"NO";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"YOur Message" message:@"Your description"
												   delegate:self cancelButtonTitle:noText otherButtonTitles:yesText, nil];
	[alert show];
    
    
}

- (IBAction)playTrafficLight:(id)sender
{
    @try {
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/trafficlight.MP3", [[NSBundle mainBundle] resourcePath]]];
        
        NSError *error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        audioPlayer.numberOfLoops = -1;
        
        [audioPlayer play];
        mlogDebug(@"%@", audioPlayer);
    }
    @catch (NSException *exception) {
        mlogDebug(@"%@", [exception reason]);
    }
    
    
    mlogDebug(@"%@", audioPlayer);
//    AudioServicesPlaySystemSound(1003);
    @try {
        [audioPlayer play];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception reason]);
    }
    
    
}
@end
