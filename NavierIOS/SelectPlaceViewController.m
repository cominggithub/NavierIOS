//
//  SelectPlaceViewController.m
//  NavierIOS
//
//  Created by Coming on 13/6/2.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "SelectPlaceViewController.h"
#import <NaviUtil/NaviUtil.h>

#define FILE_DEBUG FALSE
#include <NaviUtil/Log.h>

@interface SelectPlaceViewController ()

@end

@implementation SelectPlaceViewController
{
    SectionMode _sectionMode;
    NSMutableArray* placeIcons;
}

- (void)viewDidLoad
{
    logfn();
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;


    
    _sectionMode = kSectionMode_Home_Office_Favor;
    
    placeIcons = [[NSMutableArray alloc] initWithCapacity:kPlaceType_Max];
    [placeIcons insertObject:[UIImage imageNamed:@"search32"]   atIndex:kPlaceType_None];
    [placeIcons insertObject:[UIImage imageNamed:@"home64"]     atIndex:kPlaceType_Home];
    [placeIcons insertObject:[UIImage imageNamed:@"office64"]   atIndex:kPlaceType_Office];
    [placeIcons insertObject:[UIImage imageNamed:@"favor64"]    atIndex:kPlaceType_Favor];
    [placeIcons insertObject:[UIImage imageNamed:@"search32"]   atIndex:kPlaceType_SearchedPlace];
    
    self.tableView.delegate         = self;
    self.tableView.dataSource       = self;
//    self.tableView.backgroundColor  = [[UIColor grayColor] colorWithAlphaComponent:0.9];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [User getSectionCount:self.sectionMode];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [User getPlaceCountBySectionMode:self.sectionMode
                                    section:section];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Place* place;
    UILabel *nameLabel;
    UILabel *addressLabel;
    UITableViewCell *cell;
    
    logfn();
    logI(indexPath.row);
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"SelectPlaceCell"];
    
    if ( 3 > indexPath.section)
    {
        place = [User getPlaceBySectionMode:self.sectionMode
                                    section:indexPath.section
                                      index:indexPath.row];
    }
    else
    {
        place = [self.searchedPlaces objectAtIndex:indexPath.row];
    }

    if (nil != place)
    {
        nameLabel           = (UILabel*)[cell viewWithTag:3];
        addressLabel        = (UILabel*)[cell viewWithTag:4];
        nameLabel.text      = place.name;
        addressLabel.text   = place.address;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    Place *selectedPlace;
    selectedPlace = [User getPlaceBySectionMode:self.sectionMode
                                        section:indexPath.section
                                          index:indexPath.row];
    if (nil != selectedPlace)
    {
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(selectPlaceViewController:placeSelected:)])
        {
            [self.delegate selectPlaceViewController:self placeSelected:selectedPlace];
        }
    }
    [self dismissViewControllerAnimated:TRUE completion:nil];
}




- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return [SystemManager getLanguageString:@"Home"];
        case 1:
            return [SystemManager getLanguageString:@"Office"];
        case 2:
            return [SystemManager getLanguageString:@"Favor"];
        case 3:
            return [SystemManager getLanguageString:@"Searched Place"];
    }
    
    return @"";
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view            = [[UIView alloc] init];
    CGRect viewFrame        = CGRectMake(0, 0, self.view.bounds.size.width, 24);
    CGRect imgFrame         = CGRectMake(0, 0, 24, 24);
    UIImageView *imgView;
    PlaceType placeType;
    
    placeType = [User translatSectionIndexIntoPlaceType:self.sectionMode section:section];
    
    imgView             = [[UIImageView alloc] initWithImage:[placeIcons objectAtIndex:placeType]];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.frame       = imgFrame;
    
    [view addSubview:imgView];

    
    view.frame = viewFrame;

    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
#if 0
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 8, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    
    return view;
}

#endif

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {

        [User removePlaceBySectionMode:self.sectionMode section:indexPath.section index:indexPath.row];
        [User save];

        [self.tableView reloadData];
        
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(selectPlaceViewController:placeEdited:)])
        {
            [self.delegate selectPlaceViewController:(SelectPlaceViewController*)self placeEdited:TRUE];
        }
   }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(IBAction) pressLogoButton:(UIView*) sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}

-(IBAction) pressEditButton:(UIView*) sender
{
    if (YES == self.tableView.isEditing)
    {
        [self.tableView setEditing:NO animated:YES];
        [self.editButton setTitle:[SystemManager getLanguageString:@"Edit"] forState:UIControlStateNormal];
    }
    else
    {
        [self.tableView setEditing:YES animated:YES];
        [self.editButton setTitle:[SystemManager getLanguageString:@"Done"] forState:UIControlStateNormal];
    }
}
@end
