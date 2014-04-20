//
//  BuyAllViewController.h
//  NavierIOS
//
//  Created by Coming on 8/3/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuyUIViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@property (weak, nonatomic) IBOutlet UILabel *productDescription;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;
- (IBAction)pressBuyButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *naviLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)pressBackButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *restoreIapItemButton;
- (IBAction)pressRestorePurchasedItemButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *purchasePanel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromPlaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *toPlaceLabel;

@property (weak, nonatomic) IBOutlet UIView *routePlaceView;


@end
