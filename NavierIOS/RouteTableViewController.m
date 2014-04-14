//
//  RouteTableViewController.m
//  NavierIOS
//
//  Created by Coming on 13/3/27.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "RouteTableViewController.h"

#define FILE_DEBUG FALSE
#include <NaviUtil/Log.h>

@interface RouteTableViewController ()

@end

@implementation RouteTableViewController

@synthesize route=_route;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.route = [NaviQueryManager getRoute];
    self.startLabel.text    = [self.route getStartAddress];
    self.endLabel.text      = [self.route getEndAddress];
    self.durationLabel.text = [self.route getDurationString];
    self.distanceLabel.text = [self.route getDistanceString];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"RoutePointCell";
    UILabel *instruction;
    UILabel *distance;
    UILabel *duration;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
//    cell.textLabel.text = [NSString stringWithFormat:@"%d what is this?", indexPath.row];
    instruction         = (UILabel*)[cell viewWithTag:1];
    distance            = (UILabel*)[cell viewWithTag:2];
    duration            = (UILabel*)[cell viewWithTag:3];
    instruction.text    = [self.route getStepInstruction:(int)indexPath.row];
    distance.text       = [self.route getStepDistanceString:(int)indexPath.row];
    duration.text       = [self.route getStepDurationString:(int)indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.route getStepCount];
}


- (void)viewDidUnload {
    [self setRoutePointTable:nil];
    [self setStartLabel:nil];
    [self setEndLabel:nil];
    [self setDistanceLabel:nil];
    [self setDurationLabel:nil];
    [super viewDidUnload];
}
- (IBAction)pressBackButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

@end
