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

typedef enum
{
    kSavePlaceType_Home = 0,
    kSavePlaceType_Office,
    kSavePlaceType_Favor,
    kSavePlaceType_Max,
    
}kSavePlaceType;

@interface SavePlaceViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (nonatomic, strong) Place* currentPlace;
@property (weak, nonatomic) IBOutlet UITableView *savePlaceTableView;
@property (nonatomic) kSavePlaceType savePlaceType;
- (IBAction)pressSaveButton:(id)sender;
- (IBAction)pressBackButton:(id)sender;

@end
