//
//  GoogleMapUIViewController.m
//  NavierIOS
//
//  Created by Coming on 13/2/25.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "GoogleMapUIViewController.h"


@interface GoogleMapUIViewController ()
{
    bool isShowMarkMenu;
    UIView *markMenu;
    Place *selectedPlace;
    Place *currentPlace;
    UILabel *markMenuNameLabel;
    UILabel *markMenuSnippetLabel;
    UIButton *markMenuSetStartButton;
    UIButton *markMenuSetEndButton;
    UIButton *markMenuSaveAsHomeButton;
    UIButton *markMenuSaveAsOfficeButton;
}

@end



@implementation GoogleMapUIViewController
{
    GMSMapView *_mapView;
    NSMutableArray *_places;
}

@synthesize zoomLevel = _zoomLevel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _places = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (IBAction)pressRouteButton:(id)sender
{
    
    Route *route;
    NSArray *routePoints;
    route = [NaviQueryManager getRoute];
    routePoints = [route getRoutePolyLineCLLocation];

    self.zoomLevel = 15;
    
    GMSMarker *startOptions = [[GMSMarker alloc] init];
    GMSMarker *endOptions = [[GMSMarker alloc] init];
    
    startOptions.position = ((CLLocation *)[routePoints objectAtIndex:0]).coordinate;
    startOptions.icon = [UIImage imageNamed:@"Green_car_marker.png"];

    endOptions.position = ((CLLocation *)[routePoints objectAtIndex:routePoints.count-1]).coordinate;
    endOptions.icon = [UIImage imageNamed:@"Map-Marker-Chequered-Flag-Right-Chartreuse_marker.png"];
    
    GMSPolyline *pathOptions;
    GMSMutablePath *path;
    
    [_mapView clear];
    
    
    path = [GMSMutablePath path];

    
    for(CLLocation *location in routePoints)
    {
        [path addCoordinate:location.coordinate];
    }


    pathOptions.path = path;
    pathOptions.geodesic = NO;
    
    pathOptions.map = _mapView;
    startOptions.map = _mapView;
    endOptions.map = _mapView;

    [_mapView animateToLocation:startOptions.position];
    [_mapView animateToZoom:self.zoomLevel];
    
    
    
}

- (IBAction)pressZoomOutButton:(id)sender
{
    if(self.zoomLevel > 2)
    {
        self.zoomLevel--;
        [_mapView animateToZoom:self.zoomLevel];
    }
}

- (IBAction)pressZoomInButton:(id)sender
{

    if(self.zoomLevel < 21)
    {
        self.zoomLevel++;
        [_mapView animateToZoom:self.zoomLevel];
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
    if (_mapView == nil) {
        self.zoomLevel = 12;
        // Create a default GMSMapView, showcasing Australia.
        _mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];

        if (nil != currentPlace)
        {
            logfn();
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(currentPlace.coordinate.latitude,
                                                         currentPlace.coordinate.longitude);
            marker.title = [SystemManager getLanguageString:@"目前位置"];
            marker.snippet = [SystemManager getLanguageString:@"目前位置"];
            marker.map = _mapView;
            
            _mapView.camera = [GMSCameraPosition cameraWithLatitude:currentPlace.coordinate.latitude
                                                          longitude:currentPlace.coordinate.longitude
                                                               zoom:self.zoomLevel
                                                            bearing:10.f
                                                       viewingAngle:37.5f];
            
        }
//        _mapView.myLocationEnabled = YES;
        
    }
    
    _mapView.delegate = self;
    return _mapView;
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
    _places = [[NSMutableArray alloc] initWithCapacity:0];

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
    DownloadRequest *dr = [NaviQueryManager getPlaceDownloadRequest:place];
    dr.delegate = self;
    [NaviQueryManager download:dr];
    if (nil != place && place.length > 0)
    {
        self.titleLabel.text = place;
    }
    

}

-(void) refresh
{
    Place* firstPlace = nil;
    [_mapView clear];
    for(Place* p in _places)
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
        marker.map = _mapView;
    }
    
    if (nil != firstPlace)
    {
        [_mapView animateToLocation:firstPlace.coordinate];
    }
    
}

- (IBAction)pressNavigationButton:(id)sender {
}

-(void) downloadRequestStatusChange: (DownloadRequest*) downloadRequest
{
    bool isFail = true;
    bool updateStatus = false;
    /* search place finished */
    if(downloadRequest.status == kDownloadStatus_Finished )
    {
        NSArray* places;
        GoogleJsonStatus status = [GoogleJson getStatus:downloadRequest.filePath];
        
        if ( kGoogleJsonStatus_Ok == status)
        {
            places = [Place parseJson:downloadRequest.filePath];
            if(places != nil && places.count > 0)
            {
                [self updateSearchedPlace:places];
                isFail = false;
            }
        }
        updateStatus = true;
    }
    /* search place failed */
    else if( downloadRequest.status == kDownloadStatus_DownloadFail)
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
        [_places removeAllObjects];
    }

    /* only reserve the first three places */
    for(i=0; i<places.count && i < 3; i++)
    {
        Place *p = [places objectAtIndex:i];
        /* add the first search result no matter what */
        [_places addObject:p];

    }

    
    
    [self refresh];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    CGPoint point = [mapView.projection pointForCoordinate: coordinate];
    mlogDebug(GOOGLE_MAP_UIVIEWCONTROLLER, @"Google Map tapped at (%f,%f) on screen (%.0f, %.0f)", coordinate.latitude, coordinate.longitude, point.x, point.y);

}
- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setNavigationButton:nil];
    [self setPlaceButton:nil];
    [self setPressPlaceButton:nil];
    [super viewDidUnload];
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
    for (Place *p in _places)
    {
        if (p.coordinate.latitude == marker.position.latitude && p.coordinate.longitude == marker.position.longitude)
            return p;
    }
    
    return nil;
}
-(IBAction) pressSetStartButton:(id) sender
{
    logfn();
    [self setStart];
    [self hideMarkMenu];
}

-(IBAction) pressSetEndButton:(id) sender
{
    logfn();
    [self setEnd];
    [self hideMarkMenu];
}

-(IBAction) pressSaveAsHomeButton:(id) sender
{
    logfn();
    [self saveAsHome];
    [self hideMarkMenu];
}

-(IBAction) pressSaveAsOfficeButton:(id) sender
{
    logfn();
    [self saveAsOffice];
    [self hideMarkMenu];    
}


-(void) setStart
{
    
}

-(void) setEnd
{
    
}

-(void) saveAsHome
{
    
}

-(void) saveAsOffice
{
    
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
