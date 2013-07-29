//
//  CarPanelViewController.h
//  NavierIOS
//
//  Created by Coming on 13/6/29.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NaviUtil/NaviUtil.h>


@interface CarPanel1ViewController : UIViewController<LocationManagerDelegate>
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
@property (strong, nonatomic) UIColor *color;
- (IBAction)tagAction:(id)sender;

-(void) locationUpdate:(CLLocationCoordinate2D) location Speed:(int) speed Distance:(int) distance;
-(void) lostLocationUpdate;

@end
