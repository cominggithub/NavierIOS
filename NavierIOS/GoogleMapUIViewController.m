//
//  GoogleMapUIViewController.m
//  NavierIOS
//
//  Created by Coming on 13/2/25.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "GoogleMapUIViewController.h"
#import "SavePlaceViewController.h"
#import "SelectPlaceViewController.h"
#import "RouteNavigationViewController.h"

#define FILE_DEBUG TRUE
#include <NaviUtil/Log.h>


@interface GoogleMapUIViewController ()
{



}
@end

@implementation GoogleMapUIViewController
{
    ADBannerView *adView;
    int markMenuOffset;
    bool isShowMarkMenu;
    bool isShowMarkMenuFloat;
    UIView *markMenu;
    UIView *markMenuFloat;

    RouteNavigationViewController *routeNavigationViewController;
    Place *selectedPlace;
    
//    NSMutableArray *markerPlaces;
    

//    BOOL firstLocationUpdate;
    
//    NSMutableArray *searchedPlaces;

//    Place *currentPlace;
//    Place *routeStartPlace;
//    Place *routeEndPlace;
    
//    Route *currentRoute;
    
    UILabel *markMenuNameLabel;
    UILabel *markMenuSnippetLabel;
    UIButton *markMenuSetStartButton;
    UIButton *markMenuSetEndButton;
    UIButton *markMenuSaveAsHomeButton;
    UIButton *markMenuSaveAsOfficeButton;
    UIButton *markMenuSaveAsFavorButton;
    
    
    SavePlaceViewController *savePlaceViewController;
    SelectPlaceViewController *selectPlaceViewController;
    
    MapManager *mapManager;
    int zoomLevel;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    logfn();
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        logfn();
        self = [super init];
        if (self)
        {
        }
        logfn();
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


-(void) viewDidAppear:(BOOL)animated
{
}

- (void)viewDidLoad
{
    
    NSString* navigationText;
    NSString* placeText;
    UIFont* textFont;
    [super viewDidLoad];
    
    
    self.view.frame = [SystemManager lanscapeScreenRect];

    /* google map initialization */
    mapManager                      = [[MapManager alloc] init];
    mapManager.mapView.frame        = CGRectMake(0, 0, self.googleMapView.frame.size.width, self.googleMapView.frame.size.height);
    mapManager.mapView.delegate     = self;
    [self.googleMapView insertSubview:mapManager.mapView atIndex:0];
    
    
    textFont = [UIFont boldSystemFontOfSize:14.0];
    navigationText = [SystemManager getLanguageString:@"Navigate"];
    placeText = [SystemManager getLanguageString:@"Place"];
    
    [self.navigationButton setTitle:navigationText forState:UIControlStateNormal];
    [self.placeButton setTitle:placeText forState:UIControlStateNormal];
    
    [self addMarkMenu];
    [self addMarkMenuFloat];
    
    savePlaceViewController         = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass
                                       ([SavePlaceViewController class])];
    selectPlaceViewController       = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass
                                       ([SelectPlaceViewController class])];
    routeNavigationViewController   = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass
                                       ([RouteNavigationViewController class])];
    
    selectPlaceViewController.delegate          = self;
    markMenuOffset = 60;
    
    [self addBanner:self.contentView];
    [self showAdAnimated:NO];
    
}


- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setNavigationButton:nil];
    [self setPlaceButton:nil];
    [self setPressPlaceButton:nil];
    [self setContentView:nil];
    [self setGoogleMapView:nil];
    [self setTopView:nil];
    [self setZoomPanel:nil];
    [super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
    if(self.placeToSearch != nil && self.placeToSearch.length > 0)
    {
        [self searchPlace:self.placeToSearch];
    }

    [self showAdAnimated:NO];
    
}

#pragma  mark - Banner
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
    
    //    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
//    adView.requiredContentSizeIdentifiers      = [NSSet setWithObject:ADBannerContentSizeIdentifierLandscape];
//    adView.currentContentSizeIdentifier        = ADBannerContentSizeIdentifierLandscape;
    [adView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    adView.delegate                            = self;
    adView.accessibilityLabel                  = @"banner";


    [self.view addSubview:adView];

    [self showAdAnimated:NO];
}

- (void)showAdAnimated:(BOOL)animated
{
    if (nil == adView)
        return;
    CGRect contentFrame = [SystemManager lanscapeScreenRect];
    CGRect bannerFrame = adView.frame;
    CGRect zoomPanelFrame = self.zoomPanel.frame;
    
    if (adView.bannerLoaded)
    {
        contentFrame.size.height    -= adView.frame.size.height;
        contentFrame.origin.y        = adView.frame.size.height;
        bannerFrame.origin.y         = 0;
        
    } else
    {
        bannerFrame.origin.y = -adView.frame.size.height;
    }

    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        _contentView.frame  = contentFrame;
        _zoomPanel.frame    = zoomPanelFrame;
        adView.frame       = bannerFrame;
        
    }];
    

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

#pragma  mark - MarkMenuFloat
-(void) addMarkMenuFloat
{
    isShowMarkMenu = false;
    
    NSArray *xibContents = [[NSBundle mainBundle] loadNibNamed:@"MarkMenuFloat" owner:self options:nil];
    
    CGRect frame;
    
    frame.origin.x      = self.view.frame.size.width;
    frame.origin.y      = 0;
    frame.size.width    = 200;
    frame.size.height   = 460;
    
    
    markMenuFloat = [xibContents lastObject];
    markMenuFloat.accessibilityLabel = @"markMenuFloat";
    
    markMenuFloat.frame = frame;
    
    [self.googleMapView addSubview:markMenuFloat];
}


-(void) showMarkMenuFloat:(CGPoint) pos
{
//    if (false == isShowMarkMenuFloat)
    {
        isShowMarkMenuFloat = TRUE;
     
        CGRect frame;

        frame = markMenuFloat.frame;
        
        frame.origin.x      = pos.x;
        frame.origin.y      = pos.y;
        
        markMenuFloat.frame    = frame;
        markMenuFloat.hidden   = FALSE;
    }
}

-(void) hideMarkMenuFloat
{
    if (true == isShowMarkMenuFloat)
    {
        isShowMarkMenuFloat     = false;
        markMenuFloat.hidden   = !isShowMarkMenuFloat;

    }
    
}

#pragma  mark - MarkMenu


-(void) saveAsHome:(Place*)p
{
    if (p.placeType != kPlaceRouteType_None)
    {
        [self hideMarkMenu];
        return;
    }
    savePlaceViewController.currentPlace = p;
    savePlaceViewController.sectionMode  = kSectionMode_Home;
    [self presentViewController:savePlaceViewController animated:YES completion:nil];
}

-(void) saveAsOffice:(Place*)p
{
    if (p.placeType != kPlaceRouteType_None)
    {
        [self hideMarkMenu];
        return;
    }
    
    savePlaceViewController.currentPlace = p;
    savePlaceViewController.sectionMode  = kSectionMode_Office;
    [self presentViewController:savePlaceViewController animated:YES completion:nil];
}

-(void) saveAsFavor:(Place*)p
{
    
    if (p.placeType != kPlaceRouteType_None)
    {
        [self hideMarkMenu];
        return;
    }
    
    savePlaceViewController.currentPlace = p;
    savePlaceViewController.sectionMode  = kSectionMode_Favor;
    [self presentViewController:savePlaceViewController animated:YES completion:nil];
}


-(void) updateMarkMenu
{
    if (nil != selectedPlace)
    {
        
        markMenuNameLabel.text      = selectedPlace.name;
        markMenuSnippetLabel.text   = selectedPlace.address;
    }
}

-(void) addMarkMenu
{
    isShowMarkMenu = false;
    
    NSArray *xibContents = [[NSBundle mainBundle] loadNibNamed:@"MarkMenu" owner:self options:nil];
    
    CGRect frame;
    
    frame.origin.x      = self.view.frame.size.width;
    frame.origin.y      = 0;
    frame.size.width    = 200;
    frame.size.height   = 460;
    
    
    
    markMenu = [xibContents lastObject];
    markMenu.accessibilityLabel = @"markMenu";
    
    markMenu.frame = frame;
    

    markMenuSetStartButton      = (UIButton *)[markMenu viewWithTag:3];
    markMenuSetEndButton        = (UIButton *)[markMenu viewWithTag:4];
    markMenuSaveAsHomeButton    = (UIButton *)[markMenu viewWithTag:5];
    markMenuSaveAsOfficeButton  = (UIButton *)[markMenu viewWithTag:6];
    markMenuSaveAsFavorButton   = (UIButton *)[markMenu viewWithTag:7];
    
    
    [markMenuSetStartButton addTarget:self
                               action:@selector(pressSetStartButton:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSetEndButton addTarget:self
                             action:@selector(pressSetEndButton:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSaveAsHomeButton addTarget:self
                                 action:@selector(pressSaveAsHomeButton:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSaveAsOfficeButton addTarget:self
                                   action:@selector(pressSaveAsOfficeButton:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSaveAsFavorButton addTarget:self
                                  action:@selector(pressSaveAsFavorButton:)
                        forControlEvents:UIControlEventTouchUpInside];
    
    [self.googleMapView addSubview:markMenu];
}

-(void) showMarkMenu
{
    if (false == isShowMarkMenu)
    {
        isShowMarkMenu = true;
        [self updateMarkMenu];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.4];
        logfns("mark menu: (%f, %f) (%f, %f)\n", markMenu.frame.origin.x, markMenu.frame.origin.y, markMenu.frame.size.width, markMenu.frame.size.height);
        markMenu.frame = CGRectOffset( markMenu.frame, (-1)*markMenuOffset, 0 ); // offset by an amount
        [UIView commitAnimations];
    }
}

-(void) hideMarkMenu
{
    if (true == isShowMarkMenu)
    {
        isShowMarkMenu = false;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.4];
        markMenu.frame = CGRectOffset( markMenu.frame, markMenuOffset, 0 ); // offset by an amount
        [UIView commitAnimations];
    }
    
}

#if 0
-(void) setRouteStart:(Place*) p
{
    if ([routeEndPlace isCoordinateEqualTo:p])
    {
        routeEndPlace = nil;
    }
    
    if (![routeStartPlace isCoordinateEqualTo:p])
    {
        isRouteChanged                  = true;
        routeStartPlace.placeRouteType  = kPlaceRouteType_None;
        routeStartPlace                 = p;
        routeStartPlace.placeRouteType  = kPlaceRouteType_Start;
        [self planRoute];
    }
}

-(void) setRouteEnd:(Place*) p
{
    if ([routeStartPlace isCoordinateEqualTo:p])
    {
        routeStartPlace = nil;
    }
    
    if (![routeEndPlace isCoordinateEqualTo:p])
    {
        isRouteChanged                  = true;
        routeEndPlace.placeRouteType    = kPlaceRouteType_None;
        routeEndPlace                   = p;
        routeEndPlace.placeRouteType    = kPlaceRouteType_End;
        [self planRoute];
    }
    
}

-(void) saveAsHome:(Place*)p
{
    if (p.placeType != kPlaceRouteType_None)
    {
        [self hideMarkMenu];
        return;
    }
    savePlaceViewController.currentPlace = p;
    savePlaceViewController.sectionMode  = kSectionMode_Home;
    [self presentModalViewController:savePlaceViewController animated:YES];
}

-(void) saveAsOffice:(Place*)p
{
    if (p.placeType != kPlaceRouteType_None)
    {
        [self hideMarkMenu];
        return;
    }
    
    savePlaceViewController.currentPlace = p;
    savePlaceViewController.sectionMode  = kSectionMode_Office;
    [self presentModalViewController:savePlaceViewController animated:YES];
}

-(void) saveAsFavor:(Place*)p
{

    if (p.placeType != kPlaceRouteType_None)
    {
        [self hideMarkMenu];
        return;
    }
    
    savePlaceViewController.currentPlace = p;
    savePlaceViewController.sectionMode  = kSectionMode_Favor;
    [self presentModalViewController:savePlaceViewController animated:YES];
}


-(void) updateMarkMenu
{
    if (nil != selectedPlace)
    {
        
        markMenuNameLabel.text      = selectedPlace.name;
        markMenuSnippetLabel.text   = selectedPlace.address;
    }
}

-(void) addMarkMenu
{
    isShowMarkMenu = false;
    
    NSArray *xibContents = [[NSBundle mainBundle] loadNibNamed:@"MarkMenu" owner:self options:nil];
    
    CGRect frame;
    
    frame.origin.x      = self.view.frame.size.width;
    frame.origin.y      = 0;
    frame.size.width    = 200;
    frame.size.height   = 460;
    

    
    _markMenu = [xibContents lastObject];
    _markMenu.accessibilityLabel = @"markMenu";
    
    _markMenu.frame = frame;
    
    markMenuNameLabel           =  (UILabel *)[_markMenu viewWithTag:1];
    markMenuSnippetLabel        =  (UILabel *)[_markMenu viewWithTag:2];
    markMenuSetStartButton      = (UIButton *)[_markMenu viewWithTag:3];
    markMenuSetEndButton        = (UIButton *)[_markMenu viewWithTag:4];
    markMenuSaveAsHomeButton    = (UIButton *)[_markMenu viewWithTag:5];
    markMenuSaveAsOfficeButton  = (UIButton *)[_markMenu viewWithTag:6];
    markMenuSaveAsFavorButton   = (UIButton *)[_markMenu viewWithTag:7];
    
    
    
    [markMenuSetStartButton addTarget:self
                               action:@selector(pressSetStartButton:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSetEndButton addTarget:self
                             action:@selector(pressSetEndButton:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSaveAsHomeButton addTarget:self
                                 action:@selector(pressSaveAsHomeButton:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSaveAsOfficeButton addTarget:self
                                   action:@selector(pressSaveAsOfficeButton:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    [markMenuSaveAsFavorButton addTarget:self
                                  action:@selector(pressSaveAsFavorButton:)
                        forControlEvents:UIControlEventTouchUpInside];
    
    [self.googleMapView addSubview:_markMenu];
}

-(void) showMarkMenu
{
    if (false == isShowMarkMenu)
    {
        isShowMarkMenu = true;
        [self updateMarkMenu];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.4];
        logfns("mark menu: (%f, %f) (%f, %f)\n", _markMenu.frame.origin.x, _markMenu.frame.origin.y, _markMenu.frame.size.width, _markMenu.frame.size.height);
        _markMenu.frame = CGRectOffset( _markMenu.frame, (-1)*markMenuOffset, 0 ); // offset by an amount
        [UIView commitAnimations];
    }
}

-(void) hideMarkMenu
{
    if (true == isShowMarkMenu)
    {
        isShowMarkMenu = false;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.4];
        _markMenu.frame = CGRectOffset( _markMenu.frame, markMenuOffset, 0 ); // offset by an amount
        [UIView commitAnimations];
    }
    
}

#endif

#pragma mark - Operations
-(void) downloadRequestStatusChange: (DownloadRequest*) downloadRequest
{
#if 0
    if (nil == downloadRequest)
        return;
    if (searchPlaceDownloadRequest == downloadRequest)
    {
        [self processSearchPlaceDownloadRequestStatusChange];
    }
    else if (routeDownloadRequest == downloadRequest)
    {
        [self processRouteDownloadRequestStatusChange];
    }
#endif
}

-(void) processRouteDownloadRequestStatusChange
{
#if 0
    bool isFail = true;
    bool updateStatus = false;
    /* search place finished */
    if (routeDownloadRequest.status == kDownloadStatus_Finished)
    {
        GoogleJsonStatus status = [GoogleJson getStatus:routeDownloadRequest.filePath];
        
        if ( kGoogleJsonStatus_Ok == status)
        {
            currentRoute = [Route parseJson:routeDownloadRequest.filePath];
            [self mapRefresh];
        }
        else
        {
            updateStatus = true;
        }
    }
    /* search failed */
    else if(routeDownloadRequest.status == kDownloadStatus_DownloadFail)
    {
        updateStatus = true;
    }
    
    if (true == updateStatus && true == isFail)
    {
        self.titleLabel.text = [SystemManager getLanguageString:@"Search fail"];
    }
#endif
}

-(void) processSearchPlaceDownloadRequestStatusChange
{
#if 0
    bool isFail = true;
    bool updateStatus = false;
    /* search place finished */
    if(searchPlaceDownloadRequest.status == kDownloadStatus_Finished )
    {
        NSArray* places;
        GoogleJsonStatus status = [GoogleJson getStatus:searchPlaceDownloadRequest.filePath];
        
        if ( kGoogleJsonStatus_Ok == status)
        {
            places = [Place parseJson:searchPlaceDownloadRequest.filePath];
            if(places != nil && places.count > 0)
            {
//                [_mapManager updateSearchedPlace:places];
                isFail = false;
            }
        }
        updateStatus = true;
    }
    /* search place failed */
    else if( searchPlaceDownloadRequest.status == kDownloadStatus_DownloadFail)
    {
        updateStatus = true;
    }
    
    if (true == updateStatus && true == isFail)
    {
        self.titleLabel.text = [SystemManager getLanguageString:@"Search fail"];
    }
#endif
}

-(void) searchPlace:(NSString*) place
{
#if 0
    
    if (nil != place && place.length > 0)
    {
        searchPlaceDownloadRequest          = [NaviQueryManager getPlaceDownloadRequest:place];
        searchPlaceDownloadRequest.delegate = self;
        [NaviQueryManager download:searchPlaceDownloadRequest];
        
        self.titleLabel.text = place;
    }
#endif
}

-(void) selectPlace:(Place*) p sender:(SelectPlaceViewController*) s
{
    if (nil == p)
        return;
    
    selectedPlace = p;
    [mapManager moveToPlace:p];
}

#pragma  mark - UI Actions

- (IBAction)pressRouteButton:(id)sender
{
    
    
}

- (IBAction)pressZoomOutButton:(id)sender
{
    [mapManager zoomIn];
}

- (IBAction)pressZoomInButton:(id)sender
{
    [mapManager zoomOut];
}

- (IBAction)pressHomeButton:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)pressSearchButton:(id)sender
{
    
}

- (IBAction)pressPlaceButton:(id)sender
{
    [self hideMarkMenu];
    selectPlaceViewController.searchedPlaces = [mapManager searchedPlaces];
    [self presentViewController:selectPlaceViewController animated:YES completion:nil];
    
}

- (IBAction)pressNavigationButton:(id)sender
{
    if (YES == mapManager.hasRoute)
    {
        [routeNavigationViewController startRouteNavigationFrom:mapManager.routeStartPlace To:mapManager.routeEndPlace];
    }
}

- (IBAction)pressTestButton:(id)sender
{
    
    [self presentViewController:selectPlaceViewController animated:YES completion:nil];
    
}


-(IBAction) pressSetStartButton:(id) sender
{
    [mapManager setRouteStart:selectedPlace];
    [self hideMarkMenu];
}

-(IBAction) pressSetEndButton:(id) sender
{
    [mapManager setRouteEnd:selectedPlace];
    [self hideMarkMenu];
}

-(IBAction) pressSaveAsHomeButton:(id) sender
{
    [self saveAsHome:selectedPlace];
}

-(IBAction) pressSaveAsOfficeButton:(id) sender
{
    [self saveAsOffice:selectedPlace];
    [self hideMarkMenu];
}

-(IBAction) pressSaveAsFavorButton:(id) sender
{
    [self saveAsFavor:selectedPlace];
    [self hideMarkMenu];
}

#pragma mark - delegates

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    selectedPlace = [mapManager placeByGMSMarker:marker];
    [self showMarkMenu];
    [self updateMarkMenu];

    return NO;
}


- (void)mapView:(GMSMapView *)tmapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    CGPoint p;
    p = [tmapView.projection pointForCoordinate:coordinate];
    
//    [self showMarkMenuFloat:p];
    
    if (true == isShowMarkMenu)
    {
        [self hideMarkMenu];
    }
}

@end

