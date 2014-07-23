//
//  CarPanelViewController.h
//  NavierIOS
//
//  Created by Coming on 7/23/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NaviUtil/CarPanelViewProtocol.h>
#import "CarPanel1MenuView.h"
#import <CoreLocation/CoreLocation.h>
#import <NaviUtil/SystemManager.h>
#import <NaviUtil/LocationManager.h>

@interface CarPanelViewController : UIViewController<CarPane1MenuViewDelegate, LocationManagerDelegate, SystemManagerDelegate>
@property (weak, nonatomic) IBOutlet UIView<CarPanelViewProtocol> *contentView;


/* UI Control */
@property (nonatomic) double speed;
@property (nonatomic) double heading;
@property (strong, nonatomic) UIColor *color;
@property (nonatomic) float batteryLife;
@property (nonatomic) float networkStatus;
@property (nonatomic) BOOL gpsEnabled;
@property (nonatomic) BOOL isHud;
@property (nonatomic) BOOL isCourse;
@property (nonatomic) BOOL isSpeedUnitMph;

@property (nonatomic) BOOL lockColorSelection;

-(void)dismiss;
@end
