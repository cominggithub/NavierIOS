//
//  GoogleMapUIViewController.h
//  NavierIOS
//
//  Created by Coming on 13/2/25.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <NaviUtil/NaviUtil.h>

@interface GoogleMapUIViewController : UIViewController
/** GMSMapView managed by this controller. */
- (IBAction)pressRouteButton:(id)sender;
- (IBAction)pressZoomOutButton:(id)sender;
- (IBAction)pressZoomInButton:(id)sender;
@property (nonatomic, readonly, strong) GMSMapView *mapView;
@property (nonatomic) int zoomLevel;
@end
