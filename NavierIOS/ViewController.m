//
//  ViewController.m
//  NavierIOS
//
//  Created by Coming on 13/2/25.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "ViewController.h"
#import "RouteNavigationViewController.h"
#import "CarPanelViewController.h"

#define FILE_DEBUG FALSE
#include <NaviUtil/Log.h>

@interface ViewController ()
{
    RouteNavigationViewController *routeNavigationViewController;
    ADBannerView *adView;
    NSArray* adShowLayoutConstriants;
    NSArray* adHideLayoutConstriants;
}
@end

@implementation ViewController




-(BOOL) bannerIsVisible
{
    logfn();
    
    return SystemConfig.isAd && _bannerIsVisible;
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
    
    logfn();
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

- (IBAction)pressNaviHUD:(id)sender {
}
- (void)viewDidUnload {

    [self setSelectPlaceTableView:nil];
    [self setContentView:nil];
    [super viewDidUnload];
}

-(void) viewDidAppear:(BOOL)animated
{
    [self showAdAnimated:NO];
}
/* for UITableView */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [User getPlaceCountBySectionMode: kSectionMode_Home_Office_Favor_SearchedText Section:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Place* place;
    UILabel *nameLabel;
    UITableViewCell *cell;
    
    cell                = [self.selectPlaceTableView dequeueReusableCellWithIdentifier:@"SelectPlaceCell"];
    place               = [User getPlaceBySectionMode:kSectionMode_Home_Office_Favor_SearchedText
                                              Section:indexPath.section
                                                Index:indexPath.row];
    if (nil != place)
    {
        nameLabel           = (UILabel*)[cell viewWithTag:3];
        nameLabel.text      = place.name;
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

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    logfn();
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
  //  logfns("select %d/%d\n", indexPath.section, indexPath.row);
//    [self dismissModalViewControllerAnimated:TRUE];

    Place* routeStartPlace;
    Place* routeEndPlace;
    
    routeStartPlace = [LocationManager currentPlace];
    
    routeEndPlace = [User getPlaceBySectionMode:kSectionMode_Home_Office_Favor_SearchedText
                                        Section:indexPath.section
                                           Index:indexPath.row];
    
    logo(routeStartPlace);
    if (nil != routeStartPlace && nil != routeEndPlace && ![routeStartPlace isCoordinateEqualTo:routeEndPlace])
    {
        logfn();

        [self presentModalViewController:routeNavigationViewController animated:YES];
        [routeNavigationViewController startRouteNavigationFrom:routeStartPlace To:routeEndPlace];
    }

    logfn();

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
    label.frame = CGRectMake(0, 8, 320, 10);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:12];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;

}

#pragma mark - Banner

-(void) addBanner:(UIView*) contentView
{
    
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
        adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else {
        adView = [[ADBannerView alloc] init];
    }
    
    //    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    adView.requiredContentSizeIdentifiers   = [NSSet setWithObject:ADBannerContentSizeIdentifierLandscape];
    adView.currentContentSizeIdentifier     = ADBannerContentSizeIdentifierLandscape;
    adView.delegate     = self;
    contentView         = self.contentView;
    NSDictionary *views = NSDictionaryOfVariableBindings(adView, contentView);
    
    [adView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    logfns("\n-------------------------------------- before ad view\n");
    [self.view dumpConstraint];
    
    [self.view addSubview:adView];
    
    logfns("\n-------------------------------------- after ad view\n");
    [self.view dumpConstraint];
    
    
    for(NSLayoutConstraint *c in self.view.constraints)
    {
        logfns("self.view: 0x%X \n", (int)self.view);
        logfns("contentView 0x%X \n", (int)contentView);
        
        NSLog(@"first item: %@:0x%X, second item: %@:0x%X, fa: %d, sa: %d\n",
              c.firstItem, (int)c.firstItem, c.secondItem, (int)c.secondItem,
              c.firstAttribute, c.secondAttribute
              );
        if (c.firstItem == contentView && c.secondItem == self.view && c.firstAttribute == NSLayoutAttributeTop)
        {
            logfns("matched\n");
            [self.view removeConstraint:c];
        }
    }
    
    logfns("\n--------------------------------------\n");
    [self.view dumpConstraint];
    
    [self.view  addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[adView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    
    adShowLayoutConstriants = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[adView]-0-[contentView(288)]-0-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:views];
    
    adHideLayoutConstriants = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-32)-[adView]-0-[contentView(320)]-0-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:views];
    
    [self.view addConstraints:adShowLayoutConstriants];
    //    [self.view addConstraints:adHideLayoutConstriants];
    
    
    [self.view layoutIfNeeded];
    
    logfns("\n-------------------------------------- finally\n");
    [self.view dumpConstraint];
    
    [self showAdAnimated:NO];
    
    
}

- (void)showAdAnimated:(BOOL)animated
{

    if (adView.bannerLoaded)
    {
        [self.view removeConstraints:adHideLayoutConstriants];
        [self.view addConstraints:adShowLayoutConstriants];
    } else
    {
        [self.view removeConstraints:adShowLayoutConstriants];
        [self.view addConstraints:adHideLayoutConstriants];
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.5 animations:^{[self.view layoutIfNeeded];}];
    }
   
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
//        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // Assumes the banner view is just off the bottom of the screen.
//        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
//        [UIView commitAnimations];
        self.bannerIsVisible = YES;
        [self showAdAnimated:YES];

    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    logo(error.description);
    if (self.bannerIsVisible)
    {
        self.bannerIsVisible = NO;
        [self showAdAnimated:YES];
    }
}


- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    logfn();
    NSLog(@"Banner view is beginning an ad action");
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


-(void) viewWillAppear:(BOOL)animated
{
    [self.selectPlaceTableView reloadData];
}
@end
