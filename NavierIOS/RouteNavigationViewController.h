//
//  RouteNavigationViewController.h
//  NavierIOS
//
//  Created by Coming on 13/6/3.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NaviUtil/NaviUtil.h>

@interface RouteNavigationViewController : UIViewController
{
    LocationManager* locationManager;
    LocationSimulator *locationSimulator;
    
}
-(void) startRouteNavigationFrom:(Place*) startPlace To:(Place*) endPlace;
@end
