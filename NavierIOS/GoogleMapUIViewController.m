//
//  GoogleMapUIViewController.m
//  NavierIOS
//
//  Created by Coming on 13/2/25.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "GoogleMapUIViewController.h"


@interface GoogleMapUIViewController ()
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
    
    GMSMapView *mapView;
    int zoomLevel;
    bool isRouteChanged;
    DownloadRequest *routeDownloadRequest;
    DownloadRequest *searchPlaceDownloadRequest;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        searchedPlaces = [[NSMutableArray alloc] initWithCapacity:0];
        isRouteChanged = false;
    }
    return self;
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

- (IBAction)pressSearchButton:(id)sender {
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
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(currentPlace.coordinate.latitude,
                                                         currentPlace.coordinate.longitude);
            marker.title = [SystemManager getLanguageString:@"目前位置"];
            marker.snippet = [SystemManager getLanguageString:@"目前位置"];
            marker.map = mapView;
            
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

-(void) viewWillAppear:(BOOL)animated
{
    if(self.placeToSearch != nil && self.placeToSearch.length > 0)
    {
        
        [self searchPlace:self.placeToSearch];
    }
    self.placeToSearch = nil;
}

- (void)viewDidLoad
{
    NSString* navigationText;
    NSString* placeText;
    UIFont* textFont;
    UIView *firstSubview;
    [super viewDidLoad];

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

    [self.view dumpView];
}

-(void) addMarkMenu
{
    UIView *subView;
    isShowMarkMenu = false;

    NSArray *xibContents = [[NSBundle mainBundle] loadNibNamed:@"MarkMenu" owner:self options:nil];
    
    CGRect frame;
    frame.origin.x = 480;
    frame.origin.y = 0;
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
    
    
    subView = self.view;
    logo(subView);
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
    
    [self.view addSubview:markMenu];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
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

-(void) refresh
{
    Place* firstPlace = nil;
    [mapView clear];
    for(Place* p in searchedPlaces)
    {
        if (firstPlace == nil)
        {
            firstPlace = p;
        }
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(p.coordinate.latitude, p.coordinate.longitude);
        marker.title = p.name;
        marker.snippet = p.address;
        
        marker.icon = [UIImage imageNamed:@"searched_place_icon.png"];
        marker.map = mapView;
    }
    
    [self moveToPlace:firstPlace];
}

- (IBAction)pressNavigationButton:(id)sender {
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

-(void) processRouteDownloadRequestStatusChange
{
    bool isFail = true;
    bool updateStatus = false;
    /* search place finished */
    if(routeDownloadRequest.status == kDownloadStatus_Finished )
    {
        GoogleJsonStatus status = [GoogleJson getStatus:routeDownloadRequest.filePath];
        
        if ( kGoogleJsonStatus_Ok == status)
        {
            currentRoute = [Route parseJson:routeDownloadRequest.filePath];
            [self updateRoute];
        }
        updateStatus = true;
    }
    /* search failed */
    else if( routeDownloadRequest.status == kDownloadStatus_DownloadFail)
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

    [self refresh];
}

- (void)mapView:(GMSMapView *)tmapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    CGPoint point = [tmapView.projection pointForCoordinate: coordinate];
    mlogDebug(GOOGLE_MAP_UIVIEWCONTROLLER, @"Google Map tapped at (%f,%f) on screen (%.0f, %.0f)", coordinate.latitude, coordinate.longitude, point.x, point.y);

}
- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setNavigationButton:nil];
    [self setPlaceButton:nil];
    [self setPressPlaceButton:nil];
    [super viewDidUnload];
}

-(void) clearMapAll
{
    
}

-(void) updateRoute
{
    NSArray *routePoints;
    GMSPolyline *polyLine;
    GMSMutablePath *path;
    GMSMarker *routeStart;
    GMSMarker *routeEnd;
    
    if (nil == currentRoute || nil == routeStartPlace || nil == routeEndPlace)
        return;
 
    routePoints         = [currentRoute getRoutePolyLineCLLocation];

    routeStart          = [[GMSMarker alloc] init];
    routeStart.position = routeStartPlace.coordinate;
    routeStart.icon     = [UIImage imageNamed:@"Green_car_marker.png"];

    routeEnd            = [[GMSMarker alloc] init];
    routeEnd.position   = routeEndPlace.coordinate;
    routeEnd.icon       = [UIImage imageNamed:@"Map-Marker-Chequered-Flag-Right-Chartreuse_marker.png"];
    
    path                = [GMSMutablePath path];
    
    for(CLLocation *location in routePoints)
    {
        [path addCoordinate:location.coordinate];
    }
    
    polyLine.path       = path;
    polyLine.geodesic   = NO;

    polyLine.map        = mapView;
    routeStart.map      = mapView;
    routeEnd.map        = mapView;
    
    [mapView animateToLocation:routeStartPlace.coordinate];
    
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

-(void) showMarkMenu
{
    isShowMarkMenu = true;
    logfn();
    [self updateMarkMenu];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4];
    markMenu.frame = CGRectOffset( markMenu.frame, -100, 0 ); // offset by an amount
    [UIView commitAnimations];
}

-(void) hideMarkMenu
{
    isShowMarkMenu = false;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4];
    markMenu.frame = CGRectOffset( markMenu.frame, 100, 0 ); // offset by an amount
    [UIView commitAnimations];
    
}

-(Place*) getPlaceByGMSMarker:(GMSMarker*) marker
{
    if (nil == marker)
        return nil;
    for (Place *p in searchedPlaces)
    {
        if (p.coordinate.latitude == marker.position.latitude && p.coordinate.longitude == marker.position.longitude)
            return p;
    }
    
    return nil;
}
-(IBAction) pressSetStartButton:(id) sender
{
    logfn();
    [self setRouteStart:selectedPlace];
    [self hideMarkMenu];
}

-(IBAction) pressSetEndButton:(id) sender
{
    logfn();
    [self setRouteEnd:selectedPlace];
    [self hideMarkMenu];
}

-(IBAction) pressSaveAsHomeButton:(id) sender
{
    logfn();
    [self saveAsHome:selectedPlace];
    [self hideMarkMenu];
}

-(IBAction) pressSaveAsOfficeButton:(id) sender
{
    logfn();
    [self saveAsOffice:selectedPlace];
    [self hideMarkMenu];    
}


-(void) setRouteStart:(Place*) p
{
    if (![routeStartPlace isCoordinateEqualTo:p])
    {
        isRouteChanged = true;
        routeStartPlace = p;
        [self planRoute];
    }
}

-(void) setRouteEnd:(Place*)p
{
    if (![routeEndPlace isCoordinateEqualTo:p])
    {
        isRouteChanged = true;
        routeEndPlace = p;
        [self planRoute];
    }
}

-(void) saveAsHome:(Place*)p
{
    
}

-(void) saveAsOffice:(Place*)p
{
    
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

-(void) moveToPlace:(Place*) place
{
    if (nil != place)
    {
        [mapView animateToLocation:place.coordinate];
    }
}

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{

    selectedPlace = [self getPlaceByGMSMarker:marker];

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

@end
