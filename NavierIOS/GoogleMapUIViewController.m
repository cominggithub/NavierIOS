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
    NSMutableArray *markerPlaces;

    RouteNavigationViewController *routeNavigationViewController;

}
@end



@implementation GoogleMapUIViewController
{
    ADBannerView *_adView;
    int markMenuOffset;
    bool isShowMarkMenu;
    UIView *_markMenu;
    NSMutableArray *searchedPlaces;
    Place *selectedPlace;
    Place *currentPlace;
    Place *routeStartPlace;
    Place *routeEndPlace;
    
    Route *currentRoute;
    
    UILabel *markMenuNameLabel;
    UILabel *markMenuSnippetLabel;
    UIButton *markMenuSetStartButton;
    UIButton *markMenuSetEndButton;
    UIButton *markMenuSaveAsHomeButton;
    UIButton *markMenuSaveAsOfficeButton;
    UIButton *markMenuSaveAsFavorButton;
    
    GMSMapView *mapView;
    int zoomLevel;
    bool isRouteChanged;
    DownloadRequest *routeDownloadRequest;
    DownloadRequest *searchPlaceDownloadRequest;
    
    SavePlaceViewController *savePlaceViewController;
    SelectPlaceViewController *selectPlaceViewController;
    
    
}

#pragma  mark - Controller

- (void) addPlaceToMapMaker:(Place*) p
{
    GMSMarker *marker;
    
    if (nil == p)
        return;
    
    marker          = [[GMSMarker alloc] init];
    marker.title    = p.name;
    marker.snippet  = p.address;
    marker.position = p.coordinate;
    
    if (p.placeRouteType == kPlaceRouteType_Start)
    {
        marker.icon     = [UIImage imageNamed:@"Blue_car_marker.png"];
    }
    else if (p.placeRouteType == kPlaceRouteType_End)
    {
        marker.icon     = [UIImage imageNamed:@"Map-Marker-Chequered-Flag-Right-Chartreuse_marker.png"];
    }
    else if ( p.placeType == kPlaceType_Home)
    {
        marker.icon     = [UIImage imageNamed:@"home_marker.png"];
    }
    else if ( p.placeType == kPlaceType_Office )
    {
        marker.icon     = [UIImage imageNamed:@"office_marker.png"];
    }
    else if ( p.placeType == kPlaceType_Favor )
    {
        marker.icon     = [UIImage imageNamed:@"favor_marker.png"];
    }
    else if (p.placeRouteType == kPlaceType_CurrentPlace)
    {
        marker.icon     = [UIImage imageNamed:@"Current Location.png"];
    }
    else
    {
        marker.icon     = [UIImage imageNamed:@"default_marker"];
    }
    
    marker.map      = mapView;
    [markerPlaces addObject:p];
    
}


-(void) clearMapAll
{
    [mapView clear];
    [markerPlaces removeAllObjects];
}

-(void) downloadRequestStatusChange: (DownloadRequest*) downloadRequest
{
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(Place*) getPlaceByGMSMarker:(GMSMarker*) marker
{
    if (nil == marker)
        return nil;
    
    for (Place *p in markerPlaces)
    {
        if (true == [GeoUtil isCLLocationCoordinate2DEqual:p.coordinate To:marker.position])
            return p;
    }
    
    
    return nil;
}



-(bool) isPlaceInSearchedPlaces:(Place*) place
{
    for (Place* p in searchedPlaces)
    {
        if ( [p isCoordinateEqualTo:place])
            return true;
    }
    
    return false;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void) moveToPlace:(Place*) place
{
    if (nil != place)
    {
        [mapView animateToLocation:place.coordinate];
    }
}
-(GMSMapView *) mapView
{
    if (mapView == nil) {
        zoomLevel = 12;
        // Create a default GMSMapView, showcasing Australia.
        
        
        mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(0, 0, self.googleMapView.frame.size.width, self.googleMapView.frame.size.height)];
        
        mapView.accessibilityLabel = @"mapView";
        
        if (nil != currentPlace)
        {
            //            GMSMarker *marker = [[GMSMarker alloc] init];
            //            marker.position = CLLocationCoordinate2DMake(currentPlace.coordinate.latitude,
            //                                                         currentPlace.coordinate.longitude);
            //            marker.title = [SystemManager getLanguageString:@"目前位置"];
            //            marker.snippet = [SystemManager getLanguageString:@"目前位置"];
            //            marker.map = mapView;
            
            mapView.camera = [GMSCameraPosition cameraWithLatitude:currentPlace.coordinate.latitude
                                                         longitude:currentPlace.coordinate.longitude
                                                              zoom:zoomLevel
                                                           bearing:10.f
                                                      viewingAngle:37.5f];
            
        }
        //        mapView.myLocationEnabled = YES;
        
    }
    
    mapView.delegate = self;
    return mapView;
}
- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    
    selectedPlace = [self getPlaceByGMSMarker:marker];
    [self showMarkMenu];
    [self updateMarkMenu];
    
    return NO;
}




- (void)mapView:(GMSMapView *)tmapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{

    if (true == isShowMarkMenu)
    {
        [self hideMarkMenu];
    }
}



-(void) processRouteDownloadRequestStatusChange
{
    bool isFail = true;
    bool updateStatus = false;
    /* search place finished */
    if (routeDownloadRequest.status == kDownloadStatus_Finished)
    {
        GoogleJsonStatus status = [GoogleJson getStatus:routeDownloadRequest.filePath];
        
        if ( kGoogleJsonStatus_Ok == status)
        {
            currentRoute = [Route parseJson:routeDownloadRequest.filePath];
            [self refresh];
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
}

-(void) processSearchPlaceDownloadRequestStatusChange
{
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
                [self updateSearchedPlace:places];
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
}


-(void) planRoute
{
    
    if (isRouteChanged == true)
    {
        if (nil != routeStartPlace && nil != routeEndPlace)
        {
            if (![routeStartPlace isCoordinateEqualTo:routeEndPlace])
            {
                routeDownloadRequest = [NaviQueryManager
                                        getRouteDownloadRequestFrom:routeStartPlace.coordinate
                                        To:routeEndPlace.coordinate];
                routeDownloadRequest.delegate = self;
                
                if ([GoogleJson getStatus:routeDownloadRequest.fileName] != kGoogleJsonStatus_Ok)
                {
                    [NaviQueryManager download:routeDownloadRequest];
                }
            }
            
        }
    }
    
    isRouteChanged = false;
}




-(void) removePlaceFromSearchedPlace:(Place*) placeToRemove
{
    int i;


    for(i=0; i<searchedPlaces.count; i++)
    {
        Place* p = (Place*)[searchedPlaces objectAtIndex:i];
        if ([placeToRemove isCoordinateEqualTo:p])
        {
            [searchedPlaces removeObjectAtIndex:i];
            i--;
        }
    }
}

-(void) refresh
{
    [self clearMapAll];
    
    [self updateUserConfiguredLocation];
    [self addPlaceToMapMaker:currentPlace];
    
    for(Place* p in searchedPlaces)
    {
        if (routeStartPlace != p && routeEndPlace != p)
        {
            [self addPlaceToMapMaker:p];
        }
    }
    
    
    
    [self updateRoute];
    
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


-(void) searchPlace:(NSString*) place
{
    
    if (nil != place && place.length > 0)
    {
        searchPlaceDownloadRequest          = [NaviQueryManager getPlaceDownloadRequest:place];
        searchPlaceDownloadRequest.delegate = self;
        [NaviQueryManager download:searchPlaceDownloadRequest];
        
        self.titleLabel.text = place;
    }
}


-(void) selectPlace:(Place*) p sender:(SelectPlaceViewController*) s
{
    if (nil == p)
        return;
    [self refresh];
    [self moveToPlace:p];
    
}

- (void) updateUserConfiguredLocation
{
    int i;
    
    for(i=0; i<User.homePlaces.count; i++)
    {
        [self addPlaceToMapMaker:[User getHomePlaceByIndex:i]];
        [self removePlaceFromSearchedPlace:[User getHomePlaceByIndex:i]];
    }
    
    for(i=0; i<User.officePlaces.count; i++)
    {
        [self addPlaceToMapMaker:[User getOfficePlaceByIndex:i]];
        [self removePlaceFromSearchedPlace:[User getOfficePlaceByIndex:i]];
    }
    
    for(i=0; i<User.favorPlaces.count; i++)
    {
        [self addPlaceToMapMaker:[User getFavorPlaceByIndex:i]];
        [self removePlaceFromSearchedPlace:[User getFavorPlaceByIndex:i]];
    }
}

-(void) updateRoute
{
    NSArray *routePoints;
    GMSPolyline *polyLine;
    GMSMutablePath *path;
    
    if (nil != routeStartPlace && currentPlace != routeStartPlace)
    {
        [self addPlaceToMapMaker:routeStartPlace];
    }
    
    if (nil != routeEndPlace && currentPlace != routeEndPlace)
    {
        [self addPlaceToMapMaker:routeEndPlace];
    }

    if (nil == currentRoute || nil == routeStartPlace || nil == routeEndPlace)
    {
        return;
    }
    
    routePoints             = [currentRoute getRoutePolyLineCLLocation];
    polyLine                = [[GMSPolyline alloc] init];
    polyLine.strokeWidth    = 5;
    polyLine.strokeColor    = [UIColor redColor];
    path                    = [GMSMutablePath path];
    
    for(CLLocation *location in routePoints)
    {
        [path addCoordinate:location.coordinate];
    }
    
    polyLine.path       = path;
    polyLine.geodesic   = NO;
    polyLine.map        = mapView;
    
    
}



-(void) updateSearchedPlace:(NSArray*) places
{
    int i=0;
    Place* firstPlace = nil;
    if ( places.count < 1)
    {
        self.titleLabel.text = [SystemManager getLanguageString:@"Search fail"];
    }
    /* reserve previous search results */
    else
    {
        [searchedPlaces removeAllObjects];
    }
    
    /* only reserve the first three places */
    for(i=0; i<places.count && i < 3; i++)
    {
        Place *p = [places objectAtIndex:i];
        /* add the first search result no matter what */
        if (false == [self isPlaceInSearchedPlaces:p])
        {
            [searchedPlaces addObject:p];
            if (nil == firstPlace)
                firstPlace = p;
        }
    }
    
    [self refresh];
    [self moveToPlace:firstPlace];
}
-(void) viewWillAppear:(BOOL)animated
{
    if(self.placeToSearch != nil && self.placeToSearch.length > 0)
    {
        [self searchPlace:self.placeToSearch];
    }

    [self refresh];
    
    [self showAdAnimated:NO];
    
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

    
    markerPlaces = [[NSMutableArray alloc] initWithCapacity:0];
    currentPlace = LocationManager.currentPlace;
    
    

    [self.googleMapView insertSubview:self.mapView atIndex:0];
    searchedPlaces = [[NSMutableArray alloc] initWithCapacity:0];
    
    textFont = [UIFont boldSystemFontOfSize:14.0];
    navigationText = [SystemManager getLanguageString:@"Navigate"];
    placeText = [SystemManager getLanguageString:@"Place"];
    
    [self.navigationButton setTitle:navigationText forState:UIControlStateNormal];
    [self.placeButton setTitle:placeText forState:UIControlStateNormal];
    
    [self addMarkMenu];
    
    savePlaceViewController         = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass
                                        ([SavePlaceViewController class])];
    selectPlaceViewController       = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass
                                       ([SelectPlaceViewController class])];
    routeNavigationViewController   = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass
                                     ([RouteNavigationViewController class])];
    
    selectPlaceViewController.delegate          = self;
    isRouteChanged = false;
    markMenuOffset = 60;
    
    [self addBanner:self.contentView];
    [self showAdAnimated:NO];
    [LocationManager addDelegate:self];

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

-(void) locationUpdate:(CLLocationCoordinate2D) location Speed:(int) speed Distance:(int) distance
{
    currentPlace = LocationManager.currentPlace;
    [self refresh];
}

-(void) lostLocationUpdate
{
    
}


#pragma  mark - Banner
-(void) addBanner:(UIView*) contentView
{
    if (FALSE == [SystemConfig getBoolValue:CONFIG_IS_AD])
        return;
    
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)])
    {
        _adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else
    {
        _adView = [[ADBannerView alloc] init];
    }
    
    //    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    _adView.requiredContentSizeIdentifiers      = [NSSet setWithObject:ADBannerContentSizeIdentifierLandscape];
    _adView.currentContentSizeIdentifier        = ADBannerContentSizeIdentifierLandscape;
    _adView.delegate                            = self;
    _adView.accessibilityLabel                  = @"banner";


    [self.view addSubview:_adView];

    [self showAdAnimated:NO];
}

- (void)showAdAnimated:(BOOL)animated
{
    if (nil == _adView)
        return;
    CGRect contentFrame = [SystemManager lanscapeScreenRect];
    CGRect bannerFrame = _adView.frame;
    CGRect zoomPanelFrame = self.zoomPanel.frame;
    
    if (_adView.bannerLoaded)
    {
        contentFrame.size.height    -= _adView.frame.size.height;
        contentFrame.origin.y        = _adView.frame.size.height;
        bannerFrame.origin.y         = 0;
        
    } else
    {
        bannerFrame.origin.y = -_adView.frame.size.height;
    }

    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        _contentView.frame  = contentFrame;
        _zoomPanel.frame    = zoomPanelFrame;
        _adView.frame       = bannerFrame;
        
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

#pragma  mark - MarkMenu

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

#pragma  mark - UI Actions

- (IBAction)pressRouteButton:(id)sender
{
    
    
}

- (IBAction)pressZoomOutButton:(id)sender
{
    if(zoomLevel > 2)
    {
        zoomLevel--;
        [mapView animateToZoom:zoomLevel];
    }
}

- (IBAction)pressZoomInButton:(id)sender
{
    
    if(zoomLevel < 21)
    {
        zoomLevel++;
        [mapView animateToZoom:zoomLevel];
    }
    
}

- (IBAction)pressHomeButton:(id)sender
{
    [self dismissModalViewControllerAnimated:true];
}

- (IBAction)pressSearchButton:(id)sender
{
    
}

- (IBAction)pressPlaceButton:(id)sender
{
    [self hideMarkMenu];
    selectPlaceViewController.searchedPlaces = searchedPlaces;
    [self presentModalViewController:selectPlaceViewController animated:YES];
    
}

- (IBAction)pressNavigationButton:(id)sender
{
    if (nil != routeStartPlace && nil != routeEndPlace && ![routeStartPlace isCoordinateEqualTo:routeEndPlace])
    {
        [self presentModalViewController:routeNavigationViewController animated:YES];
        [routeNavigationViewController startRouteNavigationFrom:routeStartPlace To:routeEndPlace];
    }
}

- (IBAction)pressTestButton:(id)sender
{
    //    Place *p = [Place newPlace:@"AA" Address:@"bb" Location:CLLocationCoordinate2DMake(1, 2)];
    //    [self saveAsHome:p];
    
    [self presentModalViewController:selectPlaceViewController animated:YES];
    
}


-(IBAction) pressSetStartButton:(id) sender
{
    [self setRouteStart:selectedPlace];
    [self hideMarkMenu];
    [self refresh];
}

-(IBAction) pressSetEndButton:(id) sender
{
    [self setRouteEnd:selectedPlace];
    [self hideMarkMenu];
    [self refresh];
}

-(IBAction) pressSaveAsHomeButton:(id) sender
{
    [self saveAsHome:selectedPlace];
    [self hideMarkMenu];
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



@end

