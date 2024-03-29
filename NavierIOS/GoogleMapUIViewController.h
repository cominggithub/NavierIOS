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
#import "SelectPlaceViewController.h"
#import <iAd/iAd.h>
#import "PlaceSearchResultPanelView.h"
#import "SavePlaceViewController.h"

@interface GoogleMapUIViewController : UIViewController<GMSMapViewDelegate, SelectPlaceViewControllerDelegate, ADBannerViewDelegate, MapManagerDelegate, PlaceSearchResultPanelViewDelegate, SavePlaceViewControllerDelegate>

/** GMSMapView managed by this controller. */
-(IBAction) pressZoomOutButton:(id)sender;
-(IBAction) pressZoomInButton:(id)sender;
-(IBAction) pressHomeButton:(id)sender;
-(IBAction) pressSearchButton:(id)sender;
-(IBAction) pressPlaceButton:(id)sender;
-(IBAction) pressMyLocationButton:(id) sender;
@property (weak, nonatomic) IBOutlet UIView *routePlaceView;
@property (weak, nonatomic) IBOutlet UIButton *naviLeftButton;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *googleMapView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *zoomPanel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) NSString* placeToSearch;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *navigationButton;
@property (weak, nonatomic) IBOutlet UIButton *placeButton;

@property (nonatomic) BOOL userPlace;
- (IBAction)pressNavigationButton:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *fromPlaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toPlaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;


- (IBAction)pressTestButton:(id)sender;
-(void) searchPlace:(NSString*) placeText;


@end
