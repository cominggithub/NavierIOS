//
//  ShareViewController.h
//  NavierIOS
//
//  Created by Coming on 8/17/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *popUpView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;

- (void)showInView:(UIView *)aView;

@end
