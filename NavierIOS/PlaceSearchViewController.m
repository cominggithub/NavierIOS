//
//  PlaceSearchViewController.m
//  NavierIOS
//
//  Created by Coming on 13/5/13.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "PlaceSearchViewController.h"
#import <NaviUtil/NaviUtil.h>
#import <NaviUtil/UIImage+category.h>

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
    self.placeTextField.placeholder = [SystemManager getLanguageString:@"Place to search"];
    self.placeTextField.delegate    = self;
    
    [self.backButton setTitle:[SystemManager getLanguageString:self.backButton.titleLabel.text] forState:UIControlStateNormal];
    
    self.naviLeftButton.imageView.image = [self.naviLeftButton.imageView.image imageTintedWithColor:self.naviLeftButton.tintColor];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = TRUE;
    self.naviLeftButton.imageView.image = [self.naviLeftButton.imageView.image imageTintedWithColor:self.naviLeftButton.tintColor];
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
    UITableViewCell *cell = [self.placeTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel* placeLabel;
    placeLabel         = (UILabel*)[cell viewWithTag:9];
    
    if (User.searchedPlaceText.count > 0)
    {
        placeLabel.text    = [User getSearchedPlaceTextByIndex:(int)indexPath.row];
        //    cell.textLabel.text      = [User getSearchedPlaceTextByIndex:indexPath.row];
    }
    else
    {
        placeLabel.text    = [SystemManager getLanguageString:@"No searched records"];
    }
    return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [self dismissAndSearchPlace:[User getSearchedPlaceTextByIndex:(int)indexPath.row]];
}

- (void) dismissAndSearchPlace:(NSString*) place
{

    if (nil != place)
        place = [place trim];
    
    if( place.length > 0)
    {
        GoogleMapUIViewController* gc = (GoogleMapUIViewController*) self.navigationController.parentViewController;
//        self.presentingViewController;
        [User addSearchedPlaceText:place];
        [User save];
        [gc searchPlace:place];
    }
    
    [self.navigationController popViewControllerAnimated:TRUE];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (User.searchedPlaceText.count > 0)
        return User.searchedPlaceText.count;
    
    return 1;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self dismissAndSearchPlace:self.placeTextField.text];
    return TRUE;
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
    [self.navigationController popViewControllerAnimated:TRUE];

}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
