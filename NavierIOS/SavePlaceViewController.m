//
//  SavePlaceViewController.m
//  NavierIOS
//
//  Created by Coming on 13/6/1.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "SavePlaceViewController.h"
#import <NaviUtil/NaviUtil.h>

@interface SavePlaceViewController ()

@end

@implementation SavePlaceViewController

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
    [self updateFromCurrentPlace];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNameLabel:nil];
    [self setNameLabel:nil];
    [self setAddressLabel:nil];
    [self setSavePlaceTableView:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.currentPlace = nil;
}
- (IBAction)pressSaveButton:(id)sender
{
    switch (self.savePlaceType)
    {
        case kSavePlaceType_Home:
            [User addHomePlace:self.currentPlace];
            break;
        case kSavePlaceType_Office:
            [User addOfficePlace:self.currentPlace];
            break;
        case kSavePlaceType_Favor:
            [User addFavorPlace:self.currentPlace];
            break;
        default:
            break;
    }
    
    
    [User save];
    [self.savePlaceTableView reloadData];
    
}

- (IBAction)pressBackButton:(id)sender
{
    [self dismissModalViewControllerAnimated:true];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Place* place;
    UILabel *nameLabel;
    UILabel *addressLabel;
    UITableViewCell *cell;

    cell                = [self.savePlaceTableView dequeueReusableCellWithIdentifier:@"SavePlaceCell"];
    place               = [User getPlaceBySection:indexPath.section index:indexPath.row];
    if (nil != place)
    {
        nameLabel           = (UILabel*)[cell viewWithTag:3];
        addressLabel        = (UILabel*)[cell viewWithTag:4];
        nameLabel.text      = place.name;
        addressLabel.text   = place.address;
    }
    
    return cell;
}

-(void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
//    [self dismissAndSearchPlace:[User getSearchPlaceByIndex:indexPath.row]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [User getPlaceCountBySection:section];
}

-(void) setType:(kSavePlaceType) type
{
    self.savePlaceType = type;
}
-(void) updateFromCurrentPlace
{
    if( nil != self.currentPlace)
    {
        self.nameLabel.text     = self.currentPlace.name;
        self.addressLabel.text  = self.currentPlace.address;
    }
}


@end
