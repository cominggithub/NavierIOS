//
//  SelectPlaceViewController.m
//  NavierIOS
//
//  Created by Coming on 13/6/2.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "SelectPlaceViewController.h"
#import <NaviUtil/NaviUtil.h>
#import <NaviUtil/UIImage+category.h>
#import "GoogleUtil.h"

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
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;


    
    _sectionMode = kSectionMode_Home_Office_Favor;
    
    placeIcons = [[NSMutableArray alloc] initWithCapacity:kPlaceType_Max];
    [placeIcons insertObject:[UIImage imageNamed:@"search34"] atIndex:kPlaceType_None];
    [placeIcons insertObject:[UIImage imageNamed:@"home34"] atIndex:kPlaceType_Home];
    [placeIcons insertObject:[UIImage imageNamed:@"office34"] atIndex:kPlaceType_Office];
    [placeIcons insertObject:[UIImage imageNamed:@"favor34"] atIndex:kPlaceType_Favor];
    [placeIcons insertObject:[UIImage imageNamed:@"search34"] atIndex:kPlaceType_SearchedPlace];
    [placeIcons insertObject:[UIImage imageNamed:@"search34"] atIndex:kPlaceType_SearchedPlaceText];
    [placeIcons insertObject:[UIImage imageNamed:@"search34"] atIndex:kPlaceType_CurrentPlace];
    
    [self.backButton setTitle:[SystemManager getLanguageString:self.backButton.titleLabel.text] forState:UIControlStateNormal];
    [self.editButton setTitle:[SystemManager getLanguageString:self.editButton.titleLabel.text] forState:UIControlStateNormal];
    
    self.tableView.delegate         = self;
    self.tableView.dataSource       = self;
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_tableview.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    /* configure navigation button icon */
    self.naviLeftButton.imageView.image = [self.naviLeftButton.imageView.image imageTintedWithColor:self.naviLeftButton.tintColor];
    
//    self.tableView.backgroundColor  = [[UIColor grayColor] colorWithAlphaComponent:0.9];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = TRUE;
    self.naviLeftButton.imageView.image = [self.naviLeftButton.imageView.image imageTintedWithColor:self.naviLeftButton.tintColor];
    [self.tableView reloadData];
    
    [GoogleUtil sendScreenView:@"Select Place"];
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
                                    section:(int)section];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Place* place;
    UILabel *nameLabel;
    UILabel *addressLabel;
    UIImageView *imgView;
    UITableViewCell *cell;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"SelectPlaceCell"];
    
    if ( 3 > indexPath.section)
    {
        place = [User getPlaceBySectionMode:self.sectionMode
                                    section:(int)indexPath.section
                                      index:(int)indexPath.row];
    }
    else
    {
        place = [self.searchedPlaces objectAtIndex:indexPath.row];
    }

    if (nil != place)
    {
        imgView             = (UIImageView*)[cell viewWithTag:2];
        nameLabel           = (UILabel*)[cell viewWithTag:3];
        addressLabel        = (UILabel*)[cell viewWithTag:4];

        nameLabel.text      = place.name;
        addressLabel.text   = place.address;
        
        switch (place.placeType)
        {
            case kPlaceType_Home:
                imgView.image       = [UIImage imageNamed:@"home34"];
                break;
            case kPlaceType_Office:
                imgView.image       = [UIImage imageNamed:@"office34"];
                break;
            case kPlaceType_Favor:
                imgView.image       = [UIImage imageNamed:@"favor34"];
                break;
            default:
                imgView.image       = [UIImage imageNamed:@"favor34"];
                break;
        }
    }
    
/*
    UIImageView *cellBackView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
    cellBackView.backgroundColor=[UIColor clearColor];
    cellBackView.image = [UIImage imageNamed:@"list_bg.png"];

    UIImageView *borderView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 568, 8)];
    borderView.backgroundColor=[UIColor clearColor];
    borderView.image = [UIImage imageNamed:@"inner_showdow_bg.png"];

    
    cell.backgroundView = cellBackView;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
*/
//    [cell addSubview:borderView];
    
    
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
                                        section:(int)indexPath.section
                                          index:(int)indexPath.row];
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
    return 44;
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view;
    UIImageView *imgView;
    UILabel* headerTitle;
    PlaceType placeType;
    
    
    view                    = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 44)];
    headerTitle             = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 480, 44)];
    headerTitle.textColor   = [UIColor whiteColor];
    
    placeType = [User translatSectionIndexIntoPlaceType:self.sectionMode section:(int)section];
    
    switch(placeType)
    {
        case kPlaceType_Home:
            headerTitle.text = [SystemManager getLanguageString:@"Home"];
            break;
        case kPlaceType_Office:
            headerTitle.text = [SystemManager getLanguageString:@"Office"];
            break;
        case kPlaceType_Favor:
            headerTitle.text = [SystemManager getLanguageString:@"Favor"];
            break;
        default:
            headerTitle.text = @"";
            break;
    }

    headerTitle.text = [headerTitle.text uppercaseString];
    
    imgView = [[UIImageView alloc] initWithImage:[UIImage  imageNamed:@"h_seperator"]];
    imgView.frame = CGRectMake(0, 40, 480, 4);
    

    imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [view addSubview:headerTitle];
    [view addSubview:imgView];
    
    
    return view;
    
}



#if 0
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view            = [[UIView alloc] init];

    UILabel* headerLabel;
    CGRect viewFrame        = CGRectMake(0, 0, 568, 24);
    CGRect imgFrame         = CGRectMake(0, 0, 568, 24);
    UIImageView *imgView;

    PlaceType placeType;
    
    placeType = [User translatSectionIndexIntoPlaceType:self.sectionMode section:section];
    
    imgView             = [[UIImageView alloc] initWithImage:[placeIcons objectAtIndex:placeType]];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.frame       = imgFrame;
    
//    [view addSubview:imgView];
    
    headerLabel                     = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
    headerLabel.autoresizingMask    = UIViewAutoresizingFlexibleWidth;
    headerLabel.textColor           = [UIColor whiteColor];
    logI(section);
    
    switch (section)
    {
        case 0:
            headerLabel.text = [SystemManager getLanguageString:@"Home"];
            break;
        case 1:
            headerLabel.text =  [SystemManager getLanguageString:@"Office"];
            break;
        case 2:
            headerLabel.text =  [SystemManager getLanguageString:@"Favor"];
            break;
        default:
            headerLabel.text =  [SystemManager getLanguageString:@"GGG"];
            break;
    }
    
    
    view.frame              = viewFrame;
    view.autoresizingMask   = UIViewAutoresizingFlexibleWidth;
    [view addSubview:headerLabel];
    
    UIImageView *cellBackView=[[UIImageView alloc]initWithFrame:viewFrame];
    cellBackView.backgroundColor=[UIColor clearColor];
    
    cellBackView.contentMode = UIViewContentModeScaleToFill;
    
//    cellBackView.image = [UIImage imageNamed:@"list_bg.png"];
    cellBackView.frame = viewFrame;
    

    //[cellBackView addSubview:headerLabel];
//    return cellBackView;
    return view;
}
#endif
#if 0
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

#endif

#if 0
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
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
    
    //    [view addSubview:imgView];
    
    
    view.frame = viewFrame;
    
    UIImageView *cellBackView=[[UIImageView alloc]initWithFrame:viewFrame];
    cellBackView.backgroundColor=[UIColor clearColor];
    
    cellBackView.contentMode = UIViewContentModeScaleToFill;
    
    cellBackView.image = [UIImage imageNamed:@"list_bg.png"];
    cellBackView.frame = viewFrame;
    
    return cellBackView;
}

#endif
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

        [User removePlaceBySectionMode:self.sectionMode section:(int)indexPath.section index:(int)indexPath.row];
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
    [self.navigationController popViewControllerAnimated:TRUE];
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
