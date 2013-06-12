//
//  SavePlaceViewController.h
//  NavierIOS
//
//  Created by Coming on 13/6/1.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import "User.h"


@interface SavePlaceViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (nonatomic, strong) Place* currentPlace;
@property (weak, nonatomic) IBOutlet UITableView *savePlaceTableView;
@property (nonatomic) SectionMode sectionMode;
- (IBAction)pressSaveButton:(id)sender;
- (IBAction)pressBackButton:(id)sender;

@end
