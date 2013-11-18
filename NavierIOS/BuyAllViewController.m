//
//  BuyAllViewController.m
//  NavierIOS
//
//  Created by Coming on 8/3/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "BuyAllViewController.h"

@interface BuyAllViewController ()

@end

@implementation BuyAllViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScroller:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
}
- (IBAction)pressLogoButton:(id)sender
{
    [self dismissModalViewControllerAnimated:TRUE];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
