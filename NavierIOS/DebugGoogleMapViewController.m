//
//  DebugGoogleMapViewController.m
//  NavierIOS
//
//  Created by Coming on 11/17/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "DebugGoogleMapViewController.h"
#import <NaviUtil/NaviUtil.h>
#include "Log.h"

@interface DebugGoogleMapViewController ()

@end

@implementation DebugGoogleMapViewController
{
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:12];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    
    // Listen to the myLocation property of GMSMapView.
    
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    self.view = mapView_;
    
    mapView_.delegate = self;
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
}

- (void)dealloc {
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        printf("WWwwwWWWWWWWWWW\n");
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
    }
}

- (void)mapView:(GMSMapView *)tmapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    CGPoint p;
    p = [tmapView.projection pointForCoordinate:coordinate];
    NSLog(@"tap at coor (%.0f, %.0f)\n", coordinate.latitude, coordinate.longitude);
    NSLog(@"tap at (%.0f, %.0f)\n", p.x, p.y);
    
}

@end
