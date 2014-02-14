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

@class SavePlaceViewController;

@protocol SavePlaceViewControllerDelegate <NSObject>
-(void) savePlaceViewController:(SavePlaceViewController*) spvc placeChanged:(BOOL) placeChanged place:(Place*)place;
@end

@interface SavePlaceViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) Place* currentPlace;
@property (weak, nonatomic) IBOutlet UITableView *savePlaceTableView;
@property (nonatomic) SectionMode sectionMode;
@property id<SavePlaceViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UIButton *naviLeftButton;


- (IBAction)pressSaveButton:(id)sender;
- (IBAction)pressBackButton:(id)sender;

@end
