//
//  RouteTableViewController.h
//  NavierIOS
//
//  Created by Coming on 13/3/27.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NaviUtil/NaviUtil.h>

@interface RouteTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    
    
}

@property (weak, nonatomic) IBOutlet UITableView *routePointTable;
@property (nonatomic, strong) Route *route;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
- (IBAction)pressBackButton:(id)sender;
@end
