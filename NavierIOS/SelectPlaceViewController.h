//
//  SelectPlaceViewController.h
//  NavierIOS
//
//  Created by Coming on 13/6/2.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NaviUtil/NaviUtil.h>
@class SelectPlaceViewController;

@protocol SelectPlaceViewControllerDelegate <NSObject>
-(void) selectPlaceViewController:(SelectPlaceViewController*) s placeSelected:(Place*) p;
-(void) selectPlaceViewController:(SelectPlaceViewController*) s placeEdited:(BOOL) placeEdited;
@end

@interface SelectPlaceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) NSArray* searchedPlaces;
@property (weak, nonatomic) id<SelectPlaceViewControllerDelegate> delegate;
@property (readonly) SectionMode sectionMode;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@end
