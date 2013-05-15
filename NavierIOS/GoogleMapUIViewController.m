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
    
    GMSMarkerOptions *startOptions = [[GMSMarkerOptions alloc] init];
    GMSMarkerOptions *endOptions = [[GMSMarkerOptions alloc] init];
    
    startOptions.position = ((CLLocation *)[routePoints objectAtIndex:0]).coordinate;
    startOptions.icon = [UIImage imageNamed:@"Green_car_marker.png"];

    endOptions.position = ((CLLocation *)[routePoints objectAtIndex:routePoints.count-1]).coordinate;
    endOptions.icon = [UIImage imageNamed:@"Map-Marker-Chequered-Flag-Right-Chartreuse_marker.png"];
    
    GMSPolylineOptions *pathOptions;
    GMSMutablePath *path;
    
    [_mapView clear];
    
    
    pathOptions = [GMSPolylineOptions options];
    path = [GMSMutablePath path];
    pathOptions.color = [UIColor redColor];
    
    for(CLLocation *location in routePoints)
    {
        [path addCoordinate:location.coordinate];
    }


    pathOptions.path = path;
    pathOptions.width = 10.f;
    pathOptions.geodesic = NO;
    
    [_mapView addPolylineWithOptions:pathOptions];
    
    

    [_mapView animateToLocation:startOptions.position];
    [_mapView animateToZoom:self.zoomLevel];
    
    
    [_mapView addMarkerWithOptions:startOptions];
    [_mapView addMarkerWithOptions:endOptions];
    
    
    
}

- (IBAction)pressZoomOutButton:(id)sender
{
    if(self.zoomLevel > 2)
    {
        self.zoomLevel--;
        [_mapView animateToZoom:self.zoomLevel];
        logi(self.zoomLevel);
    }
}

- (IBAction)pressZoomInButton:(id)sender
{

    if(self.zoomLevel < 21)
    {
        self.zoomLevel++;
        [_mapView animateToZoom:self.zoomLevel];
        logi(self.zoomLevel);
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
        
        //-37.819487
        //longitude:144.965699
        //
        //
        _mapView.camera = [GMSCameraPosition cameraWithLatitude:23.845650
                                                      longitude:120.893555
//        _mapView.camera = [GMSCameraPosition cameraWithLatitude:-37.819487
//                                                      longitude:144.965699

                                                           zoom:self.zoomLevel
                                                        bearing:10.f
                                                   viewingAngle:37.5f
                           ];
        

        _mapView.myLocationEnabled = YES;
        
        
        GMSMarkerOptions *options = [[GMSMarkerOptions alloc] init];
        options.position = CLLocationCoordinate2DMake(23.845650, 120.893555);
        options.title = @"宜蘭";
        options.snippet = @"台灣";
        [_mapView addMarkerWithOptions:options];

        
    }
    
    return _mapView;
}

-(void) viewWillAppear:(BOOL)animated
{
    logfn();
    logo(self.placeToSearch);
    if(self.placeToSearch != nil && self.placeToSearch.length > 0)
    {
        
        [self searchPlace:self.placeToSearch];
    }
    self.placeToSearch = nil;
}

- (void)viewDidLoad
{

    UIView *firstSubview;
    [super viewDidLoad];

    
    [self.view dumpView];
    firstSubview = [self.view.subviews objectAtIndex:0];
    [firstSubview insertSubview:self.mapView atIndex:0];
    
//    self.view = _mapView;
	// Do any additional setup after loading the view.
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
    DownloadRequest *dr = [NaviQueryManager getPlaceSearchDownloadRequest:place];
    dr.delegate = self;
    [NaviQueryManager download:dr];
    if (nil != place && place.length > 0)
    {
        self.titleLabel.text = place;
    }
}

-(void) refresh
{
    for(Place* p in _places)
    {
        
    }
}

-(void) downloadRequestStatusChange: (DownloadRequest*) downloadRequest
{
    if(downloadRequest.status == kDownloadStatus_Finished)
    {
        NSArray* places = [Place parseJson:downloadRequest.filePath];
//        [self updateSearchedPlace:places];
    }
}

-(void) updateSearchedPlace:(NSArray*) places
{
    for(Place* p in places)
    {
        [_places addObject:p];
    }
    
    [self refresh];
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [super viewDidUnload];
}
@end
