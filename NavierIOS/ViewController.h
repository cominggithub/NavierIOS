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

- (IBAction)pressPlace:(id)sender;
- (IBAction)pressRoute:(id)sender;
- (IBAction)pressMail:(id)sender;
- (IBAction)pressTextRoute:(id)sender;
- (IBAction)pressCarPanel:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL bannerIsVisible;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *carPanelButton;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *debugConfigButton;

@end
