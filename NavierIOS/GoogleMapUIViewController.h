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


@interface GoogleMapUIViewController : UIViewController<DownloadRequestDelegate, GMSMapViewDelegate>

/** GMSMapView managed by this controller. */
- (IBAction)pressRouteButton:(id)sender;
- (IBAction)pressZoomOutButton:(id)sender;
- (IBAction)pressZoomInButton:(id)sender;
- (IBAction)pressHomeButton:(id)sender;
- (IBAction)pressSearchButton:(id)sender;

@property (strong, nonatomic) NSString* placeToSearch;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *navigationButton;
@property (weak, nonatomic) IBOutlet UIButton *placeButton;
- (IBAction)pressNavigationButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *pressPlaceButton;




-(void) downloadRequestStatusChange: (DownloadRequest*) downloadRequest;
-(void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate;
@end
