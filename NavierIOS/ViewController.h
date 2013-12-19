//
//  ViewController.h
//  NavierIOS
//
//  Created by Coming on 13/2/25.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NaviUtil/NaviUtil.h>
#import <iAd/iAd.h>


@interface ViewController : UIViewController<ADBannerViewDelegate>
{
    LocationManager* locationManager;
    LocationSimulator *locationSimulator;
}
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *carPanel_outer_circle;
@property (weak, nonatomic) IBOutlet UIImageView *carPanel_inner_circle;

- (IBAction)pressPlace:(id)sender;
- (IBAction)pressRoute:(id)sender;
- (IBAction)pressTextRoute:(id)sender;
- (IBAction)pressCarPanel:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *selectPlaceTableViewBackground;
@property (weak, nonatomic) IBOutlet UITableView *selectPlaceTableView;
@property (nonatomic) BOOL bannerIsVisible;
@property (weak, nonatomic) IBOutlet UIView *carPanelView;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *carPanelButton;

@end
