//
//  PlaceSearchViewController.m
//  NavierIOS
//
//  Created by Coming on 13/5/13.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "PlaceSearchViewController.h"
#import "Log.h"
#import "User.h"

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
    self.placeTextField.text = [SystemManager getLanguageString:@""];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)preeSearchButton:(id)sender
{
    NSString *placeToSearch = self.placeTextField.text;
    if(![self.placeTextField.text isEqualToString:[SystemManager getLanguageString:@""]])
    {

        GoogleMapUIViewController* gc = (GoogleMapUIViewController*) self.presentingViewController;
        [User addSearchedPlace:placeToSearch];
        [User save];
        gc.placeToSearch = [NSString stringWithString:placeToSearch];
    }
    
    [self dismissModalViewControllerAnimated:true];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaceCell";
    UILabel *placeLabel;
    UITableViewCell *cell = [self.placeTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    placeLabel         = (UILabel*)[cell viewWithTag:2];
    placeLabel.text    = [User getSearchPlaceByIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return User.searchedPlaces.count;
}

- (void)viewDidUnload {
    [self setPlaceTextField:nil];
    [self setPlaceTableView:nil];
    [super viewDidUnload];
    
}
@end
