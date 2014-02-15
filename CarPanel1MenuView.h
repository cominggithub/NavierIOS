//
//  CarPanel1Menu.h
//  NavierIOS
//
//  Created by Coming on 12/13/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarPanel1MenuView;

@protocol CarPane1MenuViewDelegate <NSObject>
-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm changeColor:(UIColor*) color;
-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm changeHud:(BOOL) isHud;
-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm changeSpeedUnit:(BOOL) isKmh;
-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm pressLogoButton:(BOOL) isPressed;
-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm pressCloseButton:(BOOL) isPressed;
-(void) carPanel1MenuView:(CarPanel1MenuView*) cpm pressBuyButton:(BOOL) isPressed;
@end

@interface CarPanel1MenuView : UIView
@property (weak, nonatomic) UIButton* panelColor1Button;
@property (weak, nonatomic) UIButton* panelColor2Button;
@property (weak, nonatomic) UIButton* panelColor3Button;
@property (weak, nonatomic) UIButton* panelColor4Button;
@property (weak, nonatomic) UIButton* panelColor5Button;

@property (weak, nonatomic) UIImageView* panelColor3Lock;
@property (weak, nonatomic) UIImageView* panelColor4Lock;
@property (weak, nonatomic) UIImageView* panelColor5Lock;

@property (weak, nonatomic) UIButton* speedMphButton;
@property (weak, nonatomic) UIButton* speedKmhButton;
@property (weak, nonatomic) UIButton* backIconButton;
@property (weak, nonatomic) UIButton* backButton;
@property (weak, nonatomic) UIButton* closeButton;
@property (weak, nonatomic) UISwitch* hudSwitch;
@property (weak, nonatomic) UILabel*  hudLabel;
@property (weak, nonatomic) UILabel*  speedUnitLabel;
@property (nonatomic) BOOL lockColorSelection;


@property (nonatomic) BOOL isHud;
@property (nonatomic) BOOL isSpeedUnitMph;

@property (strong, nonatomic) UIColor* panelColor;
@property (strong, nonatomic) UIColor* panelColor1;
@property (strong, nonatomic) UIColor* panelColor2;
@property (strong, nonatomic) UIColor* panelColor3;
@property (strong, nonatomic) UIColor* panelColor4;
@property (strong, nonatomic) UIColor* panelColor5;

@property (weak, nonatomic) id<CarPane1MenuViewDelegate> delegate;

@end
