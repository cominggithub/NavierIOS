//
//  RouteNavigationViewController.h
//  NavierIOS
//
//  Created by Coming on 13/6/3.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NaviUtil/NaviUtil.h>
#import "CarPanel1MenuView.h"

@interface RouteNavigationViewController : UIViewController<UITextFieldDelegate, CarPane1MenuViewDelegate>
{


}
@property (weak, nonatomic) IBOutlet UIButton *textButton;
@property (weak, nonatomic) IBOutlet UIButton *stepButton;
- (IBAction)pressTextButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *autoButton;
- (IBAction)pressAutoButton:(id)sender;
- (IBAction)pressStepButton:(id)sender;
-(void) startRouteNavigationFrom:(Place*) startPlace To:(Place*) endPlace;
@property (strong, nonatomic) Place* startPlace;
@property (strong, nonatomic) Place* endPlace;
@property (weak, nonatomic) IBOutlet GuideRouteUIView *guideRouteUIView;
@property (weak, nonatomic) IBOutlet UIView *contentView;


@property (strong, nonatomic) UIColor* color;
@property (nonatomic) BOOL isHud;
@property (nonatomic) BOOL isSpeedUnitMph;

@end
