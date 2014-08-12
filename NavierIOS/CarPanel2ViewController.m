//
//  CarPanel2ViewController.m
//  NavierIOS
//
//  Created by Coming on 7/23/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanel2ViewController.h"
#import <NaviUtil/NaviUtil.h>
#import "ClockView.h"
#import "SystemStatusView.h"
#import "CarPanel1MenuView.h"
#import "BuyUIViewController.h"
#import <NaviUtil/CarPanel2View.h>

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"


@interface CarPanel2ViewController ()
{
    CarPanel2View* _carPanel2View;
}


/* UI Control */
@property (nonatomic) double speed;
@property (nonatomic) double heading;
@property (strong, nonatomic) UIColor *color;
@property (nonatomic) float batteryLife;
@property (nonatomic) float networkStatus;
@property (nonatomic) BOOL gpsEnabled;
@property (nonatomic) BOOL isHud;
@property (nonatomic) BOOL isCourse;
@property (nonatomic) BOOL isSpeedUnitMph;


@end

@implementation CarPanel2ViewController

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [GoogleUtil sendScreenView:@"Car Panel 2"];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
