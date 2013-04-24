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

- (IBAction)pressPlace:(id)sender;
- (IBAction)pressRoute:(id)sender;
- (IBAction)pressTextRoute:(id)sender;


@end
