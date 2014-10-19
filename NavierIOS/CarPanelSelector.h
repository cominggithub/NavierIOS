//
//  CarPanelSelector.h
//  NavierIOS
//
//  Created by Coming on 10/19/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#define CAR_PANEL_1 @"carPanel1"
#define CAR_PANEL_2 @"carPanel2"
#define CAR_PANEL_3 @"carPanel3"
#define CAR_PANEL_4 @"carPanel4"

#define CAR_PANEL_USAGE_LOG @"CarPanelUsageLog"

@interface CarPanelSelector : UIView


@property (nonatomic, strong) NSArray* iapImages;

-(void)useCarPanel:(NSString*)carPanel;

@end
