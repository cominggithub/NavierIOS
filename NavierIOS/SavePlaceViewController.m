//
//  SavePlaceViewController.m
//  NavierIOS
//
//  Created by Coming on 13/6/1.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "SavePlaceViewController.h"
#import "GoogleMapUIViewController.h"
#import <NaviUtil/NaviUtil.h>

#define FILE_DEBUG FALSE
#include <NaviUtil/Log.h>

@interface SavePlaceViewController ()

@end

@implementation SavePlaceViewController
{
    NSMutableArray* placeIcons;
}

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

    self.nameTextField.delegate = self;
	// Do any additional setup after loading the view.
    
    placeIcons = [[NSMutableArray alloc] initWithCapacity:kPlaceType_Max];
    [placeIcons insertObject:[UIImage imageNamed:@"search32"]   atIndex:kPlaceType_None];
    [placeIcons insertObject:[UIImage imageNamed:@"home64"]     atIndex:kPlaceType_Home];
    [placeIcons insertObject:[UIImage imageNamed:@"office64"]   atIndex:kPlaceType_Office];
    [placeIcons insertObject:[UIImage imageNamed:@"favor64"]    atIndex:kPlaceType_Favor];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [self updateUIFromCurrentPlace];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNameTextField:nil];
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
    [self save];
}

- (IBAction)pressBackButton:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void) save
{

    [self.nameTextField resignFirstResponder];
    
    if (nil == self.currentPlace)
        return;
    
    [self updateCurrentPlaceFromUI];
    
    if (nil == self.currentPlace.name || self.currentPlace.name.length < 1)
        return;

    

    [User addPlaceBySectionMode:self.sectionMode section:0 place:self.currentPlace];
    [User updateRecentPlacesByPlace:self.currentPlace];
    [User save];

    self.currentPlace = nil;
    [self.savePlaceTableView reloadData];

    /* notify the delegate */
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(savePlaceViewController:placeChanged:)])
    {
        [self.delegate savePlaceViewController:self placeChanged:YES];
    }
    
}
-(void) setSectionMode:(SectionMode)sectionMode
{
    _sectionMode = sectionMode;
    [self.savePlaceTableView reloadData];
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 64;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Place* place;
    UILabel *nameLabel;
    UILabel *addressLabel;
    UITableViewCell *cell;
    int count;
    
    cell  = [self.savePlaceTableView dequeueReusableCellWithIdentifier:@"SavePlaceCell"];

    
    count = [User getPlaceCountBySectionMode:_sectionMode section:indexPath.row];

        
    
    place = [User getPlaceBySectionMode:_sectionMode
                                section:indexPath.section
                                  index:indexPath.row];

    nameLabel           = (UILabel*)[cell viewWithTag:3];
    addressLabel        = (UILabel*)[cell viewWithTag:4];

    if (count < 1)
    {
        nameLabel.text      = [SystemManager getLanguageString:@"No place now"];
        addressLabel.text   = @"";
    }
    else if (nil != place)
    {
        nameLabel.text      = place.name;
        addressLabel.text   = place.address;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [User getPlaceCountBySectionMode:_sectionMode section:section];
    
    if (count < 1)
        return 1;
    return [User getPlaceCountBySectionMode:_sectionMode
                                    section:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (_sectionMode)
    {
        case kSectionMode_Home:
            return [SystemManager getLanguageString:@"Home"];
        case kSectionMode_Office:
            return [SystemManager getLanguageString:@"Office"];
        case kSectionMode_Favor:
            return [SystemManager getLanguageString:@"Favor"];
        default:
            return [SystemManager getLanguageString:@"Home?"];
    }
    
    return @"Home?";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view            = [[UIView alloc] init];
    CGRect viewFrame        = CGRectMake(0, 0, self.view.bounds.size.width, 48);
    CGRect imgFrame         = CGRectMake(8, 8, 48, 48);
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

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Begin update
        [tableView beginUpdates];
        
        [User removePlaceBySectionMode:_sectionMode section:indexPath.section index:indexPath.row];
        [User save];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation: UITableViewRowAnimationFade];

        // End update
        [tableView endUpdates];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self save];
    return TRUE;
}

-(void) updateUIFromCurrentPlace
{
    if (nil != self.currentPlace)
    {
        self.nameTextField.text = self.currentPlace.name;
        self.addressLabel.text  = self.currentPlace.address;
    }
}

-(void) updateCurrentPlaceFromUI
{
    if (nil != self.currentPlace)
    {
        self.currentPlace.name = [self.nameTextField.text trim];
    }
    
}

@end
