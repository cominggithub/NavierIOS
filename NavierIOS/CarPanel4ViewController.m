//
//  CarPanel4ViewController.m
//  NavierIOS
//
//  Created by Coming on 10/7/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel4ViewController.h"
#import <NaviUtil/NaviUtil.h>
#import "GoogleUtil.h"

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"
@interface CarPanel4ViewController ()

@end

@implementation CarPanel4ViewController

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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GoogleUtil sendScreenView:@"Car Panel 4"];
}



@end
