//
//  MarkerMenuFloatView.h
//  NavierIOS
//
//  Created by Coming on 12/7/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarkerMenuFloatView : UIView

@property (weak, nonatomic) UIButton* routeStartButton;
@property (weak, nonatomic) UIButton* routeEndButton;
@property (weak, nonatomic) UIButton* saveAsHomeButton;
@property (weak, nonatomic) UIButton* saveAsOfficeButton;
@property (weak, nonatomic) UIButton* saveAsFavorButton;

-(void) showRouteButtonOnly;
-(void) show;
@end
