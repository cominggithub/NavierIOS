//
//  IAPImageCell.h
//  NavierIOS
//
//  Created by Coming on 8/3/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAPImageCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

