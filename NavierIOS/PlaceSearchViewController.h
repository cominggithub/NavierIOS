//
//  PlaceSearchViewController.h
//  NavierIOS
//
//  Created by Coming on 13/5/13.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMapUIViewController.h"

@interface PlaceSearchViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *placeTextField;
- (IBAction)preeSearchButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *placeTableView;
- (IBAction)pressPlaceTextField:(id)sender;


@end
