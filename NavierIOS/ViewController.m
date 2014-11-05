//
//  ViewController.m
//  NavierIOS
//
//  Created by Coming on 13/2/25.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "ViewController.h"
#import "RouteNavigationViewController.h"
#import "GoogleMapUIViewController.h"
#import "CarPanel1ViewController.h"
#import <NaviUtil/CoordinateTranslator.h>
#import <AVFoundation/AVFoundation.h>
#import "ShareViewController.h"
#import "BuyCollectionViewController.h"



#define FILE_DEBUG FALSE
#include <NaviUtil/Log.h>

@interface ViewController ()
{
    BOOL isBuyShown;
    BOOL isShareViewShown;
}

@end

@implementation ViewController
{
    RouteNavigationViewController *routeNavigationViewController;
    GoogleMapUIViewController *googleMapUIViewController;
    ShareViewController *shareViewController;
    BuyCollectionViewController *buyCollectionViewController;
    SLComposeViewController *twitterViewController;
    UIViewController *carPanel;
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
    UIAlertView *alert;
    Place* routeStartPlace;
    Place* routeEndPlace;
}

- (void)viewDidLoad
{
    CGFloat xoffset;
    [super viewDidLoad];
    
    
    
    [self addBanner:self.contentView];
    
    alert                           = nil;
    routeNavigationViewController   = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass ([RouteNavigationViewController class])];
    googleMapUIViewController       = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass ([GoogleMapUIViewController class])];
    shareViewController             = [[ShareViewController alloc] initWithNibName:@"ShareView" bundle:nil];
    
    oriProtraitMapButtonFrame       = self.mapButton.frame;
    oriLandscapeMapButtonFrame      = self.mapButton.frame;
    oriMapButtonAutoresizingMask    = self.mapButton.autoresizingMask;
    routeStartPlace                 = nil;
    routeEndPlace                   = nil;
    isShareViewShown                = NO;

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
                                                 name:IAP_EVENT_IAP_STATUS_RETRIEVED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"applicationDidBecomeActive"
                                               object:nil];

    
    UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"CarPanels" bundle:nil];
    carPanel = [secondStoryBoard instantiateInitialViewController];
    isBuyShown = FALSE;
    


//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil];
//    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    
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
    self.navigationController.navigationBarHidden = YES;
    [self.tableView reloadData];
    [self checkIAPItem];
#if DEBUG
    self.debugConfigButton.hidden = NO;
#elif RELEASE_TEST
    self.debugConfigButton.hidden = YES;
#elif RELEASE
    self.debugConfigButton.hidden = YES;
#endif
    
    [GoogleUtil sendScreenView:@"Main Menu"];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self showAdAnimated:NO];
    
    [self showShareView];
    
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void) checkIAPItem
{
    if (IAP_STATUS_RETRIEVED != [NavierHUDIAPHelper retrieveIap])
        self.buyButton.hidden = YES;
    
    if (YES == [NavierHUDIAPHelper hasUnbroughtIap])
    {
        self.buyButton.hidden = NO;
    }
    else
    {
        self.buyButton.hidden = YES;
    }
    self.bannerIsVisible = [SystemConfig getBoolValue:CONFIG_H_IS_AD] && (![SystemConfig getBoolValue:CONFIG_IAP_IS_ADVANCED_VERSION]);
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:IAP_EVENT_IAP_STATUS_RETRIEVED])
    {
        [self checkIAPItem];
    }
    else if ([[notification name] isEqualToString:@"applicationDidBecomeActive"])
    {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        isShareViewShown = FALSE;
        [self showShareView];
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
        nameLabel.text  = [SystemManager getLanguageString:@"No recent place"];
        icon.image      = [placeIcons objectAtIndex:kPlaceType_Favor];
    }
/*
    UIView *selectedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 52)];
    selectedView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    cell.selectedBackgroundView = selectedView;
*/
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
    if (User.recentPlaces.count < 1)
        return;
    
    routeStartPlace = [LocationManager currentPlace];
    routeEndPlace   = [User.recentPlaces objectAtIndex:indexPath.row];
    
    
    if (FALSE == [self checkNavigationCondition])
    {
        return;
    }

    [routeNavigationViewController startRouteNavigationFrom:routeStartPlace To:routeEndPlace];
    [self.navigationController pushViewController:routeNavigationViewController animated:TRUE];

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

    if (FALSE == [SystemConfig getBoolValue:CONFIG_H_IS_AD])
        return;
    
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)])
    {
        adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else
    {
        adView = [[ADBannerView alloc] init];
    }
    
//    [adView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    adView.delegate     = self;

    adView.frame = CGRectMake(0, 0, [SystemManager lanscapeScreenRect].size.width, 50);
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

- (IBAction)pressMail:(id)sender
{

    NSString* to = @"navierhudios@gmail.com";
    NSString* subject= @"Navier HUD iOS";
    NSString* body = @"";
    
    
    body = [NSString stringWithFormat:@"\n\n---------\n\n\n%@ %@\n%@, %@, %@, %@, %@, %d\n",
            [SystemConfig getStringValue:CONFIG_NAVIER_NAME],
            [SystemConfig getStringValue:CONFIG_NAVIER_VERSION],
            [SystemConfig getStringValue:CONFIG_DEVICE_MACHINE_NAME],
            [SystemConfig getStringValue:CONFIG_DEVICE_SCREEN],
            [SystemConfig getStringValue:CONFIG_DEVICE_SYSTEM_NAME],
            [SystemConfig getStringValue:CONFIG_DEVICE_SYSTEM_VERSION],
            [SystemConfig getStringValue:CONFIG_LOCALE],
            [SystemConfig getIntValue:CONFIG_USE_COUNT]*50 + ([SystemConfig getBoolValue:CONFIG_IAP_IS_ADVANCED_VERSION] ? 1:0)
            ];
    
    NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@",
                            [to stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                            [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                            [body stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];

}

- (IBAction)pressTextRoute:(id)sender
{
//    [NaviQueryManager planRouteStartLocationText:@"成大" EndLocationText:@"台南一中"];
}

- (IBAction)pressMapButton:(id)sender
{
    [self presentViewController:googleMapUIViewController animated:YES completion:nil];
}

- (IBAction)pressCarPanel:(id)sender
{
    [self.navigationController pushViewController:carPanel animated:YES];
}

- (IBAction)pressShareButton:(id)sender
{
//    [self.navigationController pushViewController:shareViewController animated:TRUE];
    [shareViewController showInView:self.view];
}

-(void)shareAppStoreLink
{
    twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    NSString *titleToShare = @"i am a string a super string the most super string that ever existed in the world of the super string universe which as it happens is very super as well";
    
    if (titleToShare.length > 140) {
        titleToShare = [titleToShare substringToIndex:140];
    }
    
    [twitterViewController setInitialText:titleToShare];
    
    if (![twitterViewController addURL:[NSURL URLWithString:@"http://google.com"]]) {
        NSLog(@"Couldn't add.");
    }
    
    //    [[[UIApplication sharedApplication].keyWindow.rootViewController].navigationController pushViewController:twitterViewController animated:TRUE];
    [self.navigationController pushViewController:twitterViewController animated:TRUE];
}

-(IBAction) pressTestButton:(id)sender
{

    
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

    @try
    {
        [audioPlayer play];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception reason]);
    }
    
    
}


#pragma mark -- operation
- (BOOL)checkNavigationCondition
{
    if (FALSE == [NaviQueryManager mapServerReachable])
    {
        [self showAlertTitle:[SystemManager getLanguageString:@"Failed to plan route"]
                     message:[SystemManager getLanguageString:@"Forget to enable network connections?"]];
        return FALSE;
    }
    
    if (nil == routeStartPlace || nil == routeEndPlace)
    {
        [self showAlertTitle:[SystemManager getLanguageString:@"No GPS Signal"] message:@""];
        return FALSE;
    }

    if (routeStartPlace.coordinate.latitude == 0 && routeStartPlace.coordinate.longitude == 0)
    {
        [self showAlertTitle:[SystemManager getLanguageString:@"No GPS Signal"] message:@""];
        return FALSE;
    }
    
    if (TRUE == [routeStartPlace isCoordinateEqualTo:routeEndPlace])
    {
        [self showAlertTitle:[SystemManager getLanguageString:@"Destination Error"] message:@""];
        return FALSE;
    }
    
    return TRUE;
}

-(void) showAlertTitle:(NSString*) title message:(NSString*) message
{
    if (nil == alert)
    {
        alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:[SystemManager getLanguageString:@"OK"] otherButtonTitles:nil,nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    alert = nil;
}


-(void)showShareView
{
    
    BOOL isShowShareView = FALSE;

    if (YES == isShareViewShown)
        return;
    
    // show share view at the second times
    if ([SystemConfig getBoolValue:CONFIG_IS_SHARE_ON_FB] == FALSE && [SystemConfig getBoolValue:CONFIG_IS_SHARE_ON_TWITTER] == FALSE)
    {
        if ([SystemConfig getIntValue:CONFIG_USE_COUNT] == 3 || [SystemConfig getIntValue:CONFIG_USE_COUNT] == 5 ||
            [SystemConfig getIntValue:CONFIG_USE_COUNT] == 7)
        {
            isShowShareView = YES;
        }
    }
    
    if (TRUE == isShowShareView)
    {
        isShareViewShown    = YES;
        [shareViewController showInView:self.view];
    }

}

@end
