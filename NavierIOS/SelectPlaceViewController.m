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
    UIButton* editButton;
    SectionMode _sectionMode;
    NSMutableArray* placeIcons;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;


    
    _sectionMode = kSectionMode_Home_Office_Favor_Searched;
    
    placeIcons = [[NSMutableArray alloc] initWithCapacity:kPlaceType_Max];
    [placeIcons insertObject:[UIImage imageNamed:@"search32"]   atIndex:kPlaceType_None];
    [placeIcons insertObject:[UIImage imageNamed:@"home64"]     atIndex:kPlaceType_Home];
    [placeIcons insertObject:[UIImage imageNamed:@"office64"]   atIndex:kPlaceType_Office];
    [placeIcons insertObject:[UIImage imageNamed:@"favor64"]    atIndex:kPlaceType_Favor];
    
    editButton                      = [[UIButton alloc] initWithFrame:CGRectMake(0, 12, 64, 43)];
    editButton.backgroundColor      = editButton.tintColor;
    editButton.titleLabel.textColor = [UIColor whiteColor];
    [editButton setTitle:[SystemManager getLanguageString:@"Edit"] forState:UIControlStateNormal];
    

    [editButton addTarget:self
                   action:@selector(pressEditButton:)
         forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewDidUnload {
    [self setSelectPlaceView:nil];
    [self setSelectPlaceTableView:nil];
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
    // Return the number of rows in the section.
    if (nil != self.searchedPlaces && self.searchedPlaces.count > 0 && section == 3)
        return self.searchedPlaces.count;
    
    return [User getPlaceCountBySectionMode:self.sectionMode
                                    section:section];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Place* place;
    UILabel *nameLabel;
    UILabel *addressLabel;
    UITableViewCell *cell;
    

    cell = [self.selectPlaceTableView dequeueReusableCellWithIdentifier:@"SelectPlaceCell"];
    
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

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
    selectedPlace = [User getPlaceBySectionMode:kSectionMode_Home_Office_Favor_Searched
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
    return 64;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    UIView *view            = [[UIView alloc] init];
    CGRect viewFrame        = CGRectMake(0, 0, self.view.bounds.size.width, 48);
    CGRect imgFrame         = CGRectMake(8, 8, 48, 48);
    CGRect editButtonFrame  = CGRectMake(viewFrame.size.width - 8 - editButton.frame.size.width, 8, editButton.frame.size.width, editButton.frame.size.height);
    UIImageView *imgView;
    PlaceType placeType;
    
    placeType = [User translatSectionIndexIntoPlaceType:self.sectionMode section:section];
    
    if (section == 0)
    {
        editButton.frame = editButtonFrame;
        [view addSubview:editButton];
    }
    
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

        [User removePlaceBySectionMode:kSectionMode_Home_Office_Favor_Searched section:indexPath.section index:indexPath.row];
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

-(IBAction) pressEditButton:(UIView*) sender
{
    if (YES == self.tableView.isEditing)
    {
        [self.tableView setEditing:NO animated:YES];
        [editButton setTitle:[SystemManager getLanguageString:@"Edit"] forState:UIControlStateNormal];
    }
    else
    {
        [self.tableView setEditing:YES animated:YES];
        [editButton setTitle:[SystemManager getLanguageString:@"Done"] forState:UIControlStateNormal];
    }
}
@end
