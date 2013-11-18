//
//  PlaceSearchViewController.m
//  NavierIOS
//
//  Created by Coming on 13/5/13.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "PlaceSearchViewController.h"
#import <NaviUtil/NaviUtil.h>

#define FILE_DEBUG FALSE
#include <NaviUtil/Log.h>

@interface PlaceSearchViewController ()

@end

@implementation PlaceSearchViewController

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
    self.placeTextField.text = [SystemManager getLanguageString:@"Place to search"];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)preeSearchButton:(id)sender
{
    [self dismissAndSearchPlace:self.placeTextField.text];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaceCell";
    UILabel *placeLabel;
    UITableViewCell *cell = [self.placeTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    placeLabel         = (UILabel*)[cell viewWithTag:2];
    placeLabel.text    = [User getSearchedPlaceTextByIndex:indexPath.row];
    return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [self dismissAndSearchPlace:[User getSearchedPlaceTextByIndex:indexPath.row]];
}

- (void) dismissAndSearchPlace:(NSString*) place
{
    if(place != nil && place.length > 0)
    {
        if(![place isEqualToString:[SystemManager getLanguageString:@"Place to search"]])
        {
        
            GoogleMapUIViewController* gc = (GoogleMapUIViewController*) self.presentingViewController;
            [User addSearchedPlaceText:[place trim]];
            [User save];
            gc.placeToSearch = [NSString stringWithString:place];
        }
    }
    
    [self dismissModalViewControllerAnimated:true];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return User.searchedPlaceText.count;
}

- (void)viewDidUnload {
    [self setPlaceTextField:nil];
    [self setPlaceTableView:nil];
    [super viewDidUnload];
    
}
- (IBAction)pressPlaceTextField:(id)sender
{
    if(self.placeTextField.text != nil && self.placeTextField.text.length > 0)
    {
        if([self.placeTextField.text isEqualToString:[SystemManager getLanguageString:@"Place to search"]])
        {
            self.placeTextField.text = @"";
        }
    }
}

- (IBAction)pressLogoButton:(id)sender
{
    [self dismissModalViewControllerAnimated:true];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
