//
//  CarPanelViewController.m
//  NavierIOS
//
//  Created by Coming on 13/6/29.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "CarPanelViewController.h"
#import <NaviUtil/NaviUtil.h>

#define FILE_DEBUG FALSE
#include <NaviUtil/Log.h>

@interface CarPanelViewController ()
{
    CarPanel1UIView *_carPanel1;
    NSTimer *_redrawTimer;
    int _redrawInterval;
}
@end

@implementation CarPanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void) initSelf
{
    _redrawInterval = 0.5;
    _redrawTimer    = nil;
}

- (void)viewDidLoad
{
    [self initSelf];
    _carPanel1 = (CarPanel1UIView*)_contentView;
    [_carPanel1 start];
    [LocationManager startLocationSimulation];
    
    [super viewDidLoad];
    
    _carPanel1.color = SystemConfig.defaultColor;
    self.color = SystemConfig.defaultColor;
    [self.speedLabel setFont:[UIFont fontWithName:@"JasmineUPC" size:220]];
	// Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated
{

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tagAction:(id)sender
{
    [LocationManager stopLocationSimulation];
    [self dismissModalViewControllerAnimated:YES];
}

-(void) setColor:(UIColor*) color
{
    _color                      = color;
    _speedLabel.textColor       = _color;
    _speedUnitLabel.textColor   = _color;
    _timeLabel.textColor        = _color;
    _timeUnitLabel.textColor    = _color;
    [_batteryImage setImageTintColor:_color];
    [_gpsImage setImageTintColor:_color];
    [_threeGImage setImageTintColor:_color];
    [_courseFrameImage setImageTintColor:_color];
}
- (void)viewDidUnload {
    [self setContentView:nil];
    [self setSpeedLabel:nil];
    [self setSpeedUnitLabel:nil];
    [self setTimeLabel:nil];
    [self setSpeedUnitLabel:nil];
    [self setTimeUnitLabel:nil];
    [self setBatteryImage:nil];
    [self setThreeGImage:nil];
    [self setGpsImage:nil];
    [self setCourseFrameImage:nil];
    [super viewDidUnload];
}

-(void) autoRedrawStart
{
    if (nil == _redrawTimer)
    {
        _redrawTimer = [NSTimer scheduledTimerWithTimeInterval:_redrawInterval target:self selector:@selector(redrawTimeout) userInfo:nil repeats:YES];
    }
}

-(void) autoRedrawStop
{
    if (nil != _redrawTimer)
    {
        [_redrawTimer invalidate];
        _redrawTimer = nil;
    }
}

-(void) redrawTimeout
{
    [_carPanel1 setNeedsDisplay];

}


@end
