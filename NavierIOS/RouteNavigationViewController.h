//
//  RouteNavigationViewController.h
//  NavierIOS
//
//  Created by Coming on 13/6/3.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NaviUtil/NaviUtil.h>

@interface RouteNavigationViewController : UIViewController<UITextFieldDelegate>
{

    
}
@property (weak, nonatomic) IBOutlet UIButton *autoButton;
- (IBAction)pressAutoButton:(id)sender;
- (IBAction)pressStepButton:(id)sender;
-(void) startRouteNavigationFrom:(Place*) startPlace To:(Place*) endPlace;
@property (strong, nonatomic) Place* startPlace;
@property (strong, nonatomic) Place* endPlace;
@property (weak, nonatomic) IBOutlet GuideRouteUIView *guideRouteUIView;


@end
