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


@interface GoogleMapUIViewController ()
{
    NSMutableArray *markerPlaces;
}
@end



@implementation GoogleMapUIViewController
{
    bool isShowMarkMenu;
    UIView *markMenu;
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


-(void) addMarkMenu
{
    UIView *subView;
    isShowMarkMenu = false;

    NSArray *xibContents = [[NSBundle mainBundle] loadNibNamed:@"MarkMenu" owner:self options:nil];
    
    CGRect frame;
    frame.origin.x = 480;
    frame.origin.y = 28;
    //    frame.size = self.scrIcon.frame.size;
    frame.size.width = 200;
    frame.size.height = 480;
    
    markMenu = [xibContents lastObject]; //safer than objectAtIndex:0
    markMenu.frame = frame;
    
    markMenuNameLabel           =  (UILabel *)[markMenu viewWithTag:1];
    markMenuSnippetLabel        =  (UILabel *)[markMenu viewWithTag:2];
    markMenuSetStartButton      = (UIButton *)[markMenu viewWithTag:3];
    markMenuSetEndButton        = (UIButton *)[markMenu viewWithTag:4];
    markMenuSaveAsHomeButton    = (UIButton *)[markMenu viewWithTag:5];
    markMenuSaveAsOfficeButton  = (UIButton *)[markMenu viewWithTag:6];
    markMenuSaveAsFavorButton   = (UIButton *)[markMenu viewWithTag:7];
    
    
    subView = self.view;

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
    
    [self.view addSubview:markMenu];
}

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
    else
    {
        marker.icon     = [UIImage imageNamed:@"default_marker.png"];
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
-(void) hideMarkMenu
{
    isShowMarkMenu = false;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4];
    logfns("mark menu: (%f, %f) (%f, %f)\n", markMenu.frame.origin.x, markMenu.frame.origin.y, markMenu.frame.size.width, markMenu.frame.size.height);
    markMenu.frame = CGRectOffset( markMenu.frame, 100, 0 ); // offset by an amount
    [UIView commitAnimations];
    
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
        mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
        
        if (nil != currentPlace)
        {
            logfn();
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
    
    logo(selectedPlace);
    if (false == isShowMarkMenu)
    {
        [self showMarkMenu];
    }
    else
    {
        [self updateMarkMenu];
    }
    return NO;
}




- (void)mapView:(GMSMapView *)tmapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    CGPoint point = [tmapView.projection pointForCoordinate: coordinate];
    mlogDebug(GOOGLE_MAP_UIVIEWCONTROLLER, @"Google Map tapped at (%f,%f) on screen (%.0f, %.0f)", coordinate.latitude, coordinate.longitude, point.x, point.y);

}








- (IBAction)pressNavigationButton:(id)sender {
}

- (IBAction)pressTestButton:(id)sender
{
    //    Place *p = [Place newPlace:@"AA" Address:@"bb" Location:CLLocationCoordinate2DMake(1, 2)];
    //    [self saveAsHome:p];
    
    [self presentModalViewController:selectPlaceViewController animated:YES];
    
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
            [self refresh:false];
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



-(IBAction) pressSetStartButton:(id) sender
{
    [self setRouteStart:selectedPlace];
    [self hideMarkMenu];
    [self refresh:false];
}

-(IBAction) pressSetEndButton:(id) sender
{
    [self setRouteEnd:selectedPlace];
    [self hideMarkMenu];
    [self refresh:false];
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





-(void) planRoute
{
    
    if (isRouteChanged == true)
    {
        if (nil != routeStartPlace && nil != routeEndPlace)
        {
            if (![routeStartPlace isCoordinateEqualTo:routeEndPlace])
            {
                logfn();
                logo(routeStartPlace);
                logo(routeEndPlace);
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

-(void) refresh:(bool) moveCamera
{
    Place* firstPlace = nil;
    [self clearMapAll];
    
    for(Place* p in searchedPlaces)
    {
        if (firstPlace == nil)
        {
            firstPlace = p;
        }
        [self addPlaceToMapMaker:p];
    }
    
    [self updateUserConfiguredLocation];
    [self updateRoute];
    
    if (moveCamera)
    {
        if (nil != routeStartPlace)
            [self moveToPlace:routeStartPlace];
        else if (nil != firstPlace)
            [self moveToPlace:firstPlace];
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

-(void) showMarkMenu
{
    isShowMarkMenu = true;
    [self updateMarkMenu];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4];
    logfns("mark menu: (%f, %f) (%f, %f)\n", markMenu.frame.origin.x, markMenu.frame.origin.y, markMenu.frame.size.width, markMenu.frame.size.height);
    markMenu.frame = CGRectOffset( markMenu.frame, -100, 0 ); // offset by an amount
    [UIView commitAnimations];
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
    savePlaceViewController.currentPlace = p;
    [savePlaceViewController setType:kSavePlaceType_Home];
    [self presentModalViewController:savePlaceViewController animated:YES];
}

-(void) saveAsOffice:(Place*)p
{
    savePlaceViewController.currentPlace = p;
    [savePlaceViewController setType:kSavePlaceType_Office];
    [self presentModalViewController:savePlaceViewController animated:YES];
}

-(void) saveAsFavor:(Place*)p
{
    savePlaceViewController.currentPlace = p;
    [savePlaceViewController setType:kSavePlaceType_Favor];
    [self presentModalViewController:savePlaceViewController animated:YES];
}

- (void) updateUserConfiguredLocation
{
    int i;
    
    for(i=0; i<User.homeLocations.count; i++)
    {
        [self addPlaceToMapMaker:[User getHomeLocationByIndex:i]];
    }
    
    for(i=0; i<User.officeLocations.count; i++)
    {
        [self addPlaceToMapMaker:[User getOfficeLocationByIndex:i]];
    }
    
    for(i=0; i<User.favorLocations.count; i++)
    {
        [self addPlaceToMapMaker:[User getFavorLocationByIndex:i]];
    }
}

-(void) updateRoute
{
    NSArray *routePoints;
    GMSPolyline *polyLine;
    GMSMutablePath *path;
    
    if (nil != routeStartPlace)
    {
        [self addPlaceToMapMaker:routeStartPlace];
    }
    
    if (nil != routeEndPlace)
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
    
    
//    [mapView animateToLocation:routeStartPlace.coordinate];
    
}

-(void) updateMarkMenu
{
    if (nil != selectedPlace)
    {
        logo(selectedPlace);
        markMenuNameLabel.text      = selectedPlace.name;
        markMenuSnippetLabel.text   = selectedPlace.address;
    }
}

-(void) updateSearchedPlace:(NSArray*) places
{
    int i=0;
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
        [searchedPlaces addObject:p];
        
    }
    
    [self refresh:true];
}
-(void) viewWillAppear:(BOOL)animated
{
    if(self.placeToSearch != nil && self.placeToSearch.length > 0)
    {
        
        [self searchPlace:self.placeToSearch];
    }
    self.placeToSearch = nil;
    [self refresh:false];
}
- (void)viewDidLoad
{
    NSString* navigationText;
    NSString* placeText;
    UIFont* textFont;
    UIView *firstSubview;
    [super viewDidLoad];
    
    markerPlaces = [[NSMutableArray alloc] initWithCapacity:0];
    currentPlace = [LocationManager getCurrentPlace];
    
    
    firstSubview = [self.view.subviews objectAtIndex:0];
    [firstSubview insertSubview:self.mapView atIndex:0];
    searchedPlaces = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    
    textFont = [UIFont boldSystemFontOfSize:14.0];
    navigationText = [SystemManager getLanguageString:@"Navigation"];
    placeText = [SystemManager getLanguageString:@"Place"];
    [self.navigationButton setTitle:navigationText forState:UIControlStateNormal];
    [self.placeButton setTitle:placeText forState:UIControlStateNormal];
    
    [self addMarkMenu];
    
    savePlaceViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass
                               ([SavePlaceViewController class])];
    
    selectPlaceViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass
                                 ([SelectPlaceViewController class])];
    isRouteChanged = false;
    
    //  [self.view dumpView];
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setNavigationButton:nil];
    [self setPlaceButton:nil];
    [self setPressPlaceButton:nil];
    [super viewDidUnload];
}

@end
