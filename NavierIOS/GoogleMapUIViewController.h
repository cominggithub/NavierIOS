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


@interface GoogleMapUIViewController : UIViewController<DownloadRequestDelegate>

/** GMSMapView managed by this controller. */
- (IBAction)pressRouteButton:(id)sender;
- (IBAction)pressZoomOutButton:(id)sender;
- (IBAction)pressZoomInButton:(id)sender;
- (IBAction)pressHomeButton:(id)sender;
- (IBAction)pressSearchButton:(id)sender;
@property (nonatomic, readonly, strong) GMSMapView *mapView;
@property (nonatomic) int zoomLevel;
@property (strong, nonatomic) NSString* placeToSearch;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

-(void) downloadRequestStatusChange: (DownloadRequest*) downloadRequest;
@end
