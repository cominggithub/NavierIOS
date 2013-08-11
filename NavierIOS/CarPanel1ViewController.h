//
//  CarPanelViewController.h
//  NavierIOS
//
//  Created by Coming on 13/6/29.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NaviUtil/NaviUtil.h>


@interface CarPanel1ViewController : UIViewController<LocationManagerDelegate, SystemManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *networkLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLifeLabel;
@property (weak, nonatomic) IBOutlet UIView *courseLabelView;
@property (weak, nonatomic) IBOutlet UILabel *courseCutLabel;

@property (weak, nonatomic) IBOutlet UIView *courseLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseSWLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseWLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseNWLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseNLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseNELabel;
@property (weak, nonatomic) IBOutlet UILabel *courseELabel;
@property (weak, nonatomic) IBOutlet UILabel *courseSELabel;
@property (weak, nonatomic) IBOutlet UILabel *courseSLabel;
@property (weak, nonatomic) IBOutlet UIView *courseView;

@property (weak, nonatomic) IBOutlet UILabel *clockSecondLabel;
@property (weak, nonatomic) IBOutlet UILabel *clockHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *clockMinuteLabel;

@property (weak, nonatomic) IBOutlet UILabel *clockUnitLabel;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedUnitLabel;
@property (weak, nonatomic) IBOutlet UIImageView *batteryImage;
@property (weak, nonatomic) IBOutlet UIImageView *threeGImage;
@property (weak, nonatomic) IBOutlet UIImageView *gpsImage;
@property (weak, nonatomic) IBOutlet UIImageView *courseFrameImage;
@property (nonatomic) int speed;
@property (nonatomic) double heading;
@property (strong, nonatomic) UIColor *color;


@property (nonatomic) float batteryLife;
@property (nonatomic) float networkStatus;
@property (nonatomic) BOOL gpsEnabled;
@property (nonatomic) CGRect courseLabelRect;
@property (nonatomic) BOOL isHud;
@property (nonatomic) BOOL isCourse;
@property (nonatomic) BOOL isSpeedUnitMph;

- (IBAction)tagAction:(id)sender;

-(void) locationUpdate:(CLLocationCoordinate2D) location speed:(int) speed distance:(int) distance heading:(double) heading;
-(void) lostLocationUpdate;


@end
