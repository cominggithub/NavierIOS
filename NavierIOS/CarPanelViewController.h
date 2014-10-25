//
//  CarPanelViewController.h
//  NavierIOS
//
//  Created by Coming on 7/23/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NaviUtil/CarPanelViewProtocol.h>
#import "CarPanelMenuView.h"
#import <CoreLocation/CoreLocation.h>
#import <NaviUtil/SystemManager.h>
#import <NaviUtil/LocationManager.h>

@interface CarPanelViewController : UIViewController<CarPanelMenuViewDelegate, LocationManagerDelegate, SystemManagerDelegate>
@property (weak, nonatomic) IBOutlet UIView<CarPanelViewProtocol> *contentView;


/* UI Control */
@property (nonatomic, copy) NSString *carPanelName;
@property (nonatomic) double speed;
@property (nonatomic) double heading;
@property (strong, nonatomic) UIColor *color;
@property (nonatomic) BOOL isHud;
@property (nonatomic) BOOL isCourse;
@property (nonatomic) BOOL isSpeedUnitMph;
@property (nonatomic) CLLocationCoordinate2D location;

@property (nonatomic) BOOL lockColorSelection;

-(void)dismiss;

@end
