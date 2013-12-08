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

    if (nil == self.currentPlace)
        return;
    
    [self updateCurrentPlaceFromUI];
    
    if (nil == self.currentPlace.name || self.currentPlace.name.length < 1)
        return;

    

    [User addPlaceBySectionMode:self.sectionMode section:0 place:self.currentPlace];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Place* place;
    UILabel *nameLabel;
    UILabel *addressLabel;
    UITableViewCell *cell;

    cell                = [self.savePlaceTableView dequeueReusableCellWithIdentifier:@"SavePlaceCell"];

    place = [User getPlaceBySectionMode:_sectionMode
                                section:indexPath.section
                                  index:indexPath.row];
    
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
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, 320, 20);
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

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
