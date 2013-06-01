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
{
    NSArray* locationArray;
}
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
            [User addHomeLocation:self.currentPlace];
            break;
        case kSavePlaceType_Office:
            [User addOfficeLocation:self.currentPlace];
            break;
        case kSavePlaceType_Favor:
            [User addFavorLocation:self.currentPlace];
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
    place               = (Place*) [self getPlaceByIndex:indexPath.row];
    nameLabel           = (UILabel*)[cell viewWithTag:3];
    addressLabel        = (UILabel*)[cell viewWithTag:4];
    nameLabel.text      = place.name;
    addressLabel.text   = place.address;
    
    return cell;
}

-(Place*) getPlaceByIndex:(int) index
{
    switch (self.savePlaceType)
    {
        case kSavePlaceType_Home:
            return [User getHomeLocationByIndex:index];
        case kSavePlaceType_Office:
            return [User getOfficeLocationByIndex:index];
        case kSavePlaceType_Favor:
            return [User getFavorLocationByIndex:index];
        default:
            return nil;
            break;
    }
    
    return nil;
    
}

-(void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
//    [self dismissAndSearchPlace:[User getSearchPlaceByIndex:indexPath.row]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( nil != locationArray )
        return locationArray.count;

    return 0;
}

-(void) setType:(kSavePlaceType) type
{
    self.savePlaceType = type;
    switch (self.savePlaceType)
    {
        case kSavePlaceType_Home:
            locationArray = User.homeLocations;
            break;
        case kSavePlaceType_Office:
            locationArray = User.officeLocations;
            break;
        case kSavePlaceType_Favor:
            locationArray = User.favorLocations;
            break;
        default:
            break;
    }

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
