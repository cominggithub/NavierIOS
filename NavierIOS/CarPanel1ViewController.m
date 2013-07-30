//
//  CarPanelViewController.m
//  NavierIOS
//
//  Created by Coming on 13/6/29.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "CarPanel1ViewController.h"
#import <NaviUtil/NaviUtil.h>

#define FILE_DEBUG FALSE
#include <NaviUtil/Log.h>

@interface CarPanel1ViewController ()
{
    CarPanel1UIView *_carPanel1;
    NSTimer *_redrawTimer;
    int _redrawInterval;
    NSTimer *_clockTimer;
    NSDateFormatter *_clockTimerFormater;
    NSMutableArray *_courseLabelArray;
}
@end

@implementation CarPanel1ViewController

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
    
    [super viewDidLoad];
    

    _clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
  
    _clockTimerFormater = [[NSDateFormatter alloc] init];
    [_clockTimerFormater setDateFormat:@"HH:mm:ss"];

    [_clockHourLabel    setFont:[UIFont fontWithName:@"JasmineUPC" size:50]];
    [_clockMinuteLabel  setFont:[UIFont fontWithName:@"JasmineUPC" size:50]];
    [_clockUnitLabel    setFont:[UIFont fontWithName:@"JasmineUPC" size:25]];
    [_speedLabel        setFont:[UIFont fontWithName:@"JasmineUPC" size:220]];
    [_speedUnitLabel    setFont:[UIFont fontWithName:@"JasmineUPC" size:35]];
    
    _courseLabelArray = [[NSMutableArray alloc] initWithCapacity:8];
    [_courseLabelArray addObject:self.courseNLabel];
    [_courseLabelArray addObject:self.courseNELabel];
    [_courseLabelArray addObject:self.courseELabel];
    [_courseLabelArray addObject:self.courseSELabel];
    [_courseLabelArray addObject:self.courseSLabel];
    [_courseLabelArray addObject:self.courseSWLabel];
    [_courseLabelArray addObject:self.courseWLabel];
    [_courseLabelArray addObject:self.courseNWLabel];
    
    self.color = [SystemConfig defaultColor];
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
    _clockHourLabel.textColor   = _color;
    _clockMinuteLabel.textColor = _color;
    _clockUnitLabel.textColor   = _color;
    [_batteryImage setImageTintColor:_color];
    [_gpsImage setImageTintColor:_color];
    [_threeGImage setImageTintColor:_color];
    [_courseFrameImage setImageTintColor:_color];
    
    for (UILabel* l in _courseLabelArray)
    {
        l.textColor = _color;
    }
}

- (void)viewDidUnload
{
    [self setContentView:nil];
    [self setSpeedLabel:nil];
    [self setSpeedUnitLabel:nil];
    [self setSpeedUnitLabel:nil];
    [self setClockUnitLabel:nil];
    [self setBatteryImage:nil];
    [self setThreeGImage:nil];
    [self setGpsImage:nil];
    [self setCourseFrameImage:nil];
    [self setClockUnitLabel:nil];
    [self setClockHourLabel:nil];
    [self setClockMinuteLabel:nil];
    [self setClockSecondLabel:nil];
    [self setCourseSWLabel:nil];
    [self setCourseWLabel:nil];
    [self setCourseNWLabel:nil];
    [self setCourseNLabel:nil];
    [self setCourseNELabel:nil];
    [self setCourseELabel:nil];
    [self setCourseSELabel:nil];
    [self setCourseSLabel:nil];
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

-(void) updateClock
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    NSInteger hour      = [components hour];
    NSInteger minute    = [components minute];
    
    if (hour >= 12)
    {
        hour -= 12;
        _clockUnitLabel.text = [SystemManager getLanguageString:@"pm"];
    }
    else
    {
        _clockUnitLabel.text = [SystemManager getLanguageString:@"am"];
    }
    
    _clockHourLabel.text        = [NSString stringFromInt:hour numOfDigits:2];
    _clockMinuteLabel.text      = [NSString stringFromInt:minute numOfDigits:2];
    _clockSecondLabel.hidden    = !_clockSecondLabel.hidden;
    self.speed++;
}

-(void) setSpeed:(int)speed
{
    _speed = speed;
    _speedLabel.text = [NSString stringFromInt:_speed];
}

-(void) locationUpdate:(CLLocationCoordinate2D) location speed:(int) speed distance:(int) distance heading:(double) heading
{
    self.speed      = speed;
    self.heading    = heading;
    
}

-(void) lostLocationUpdate
{
    
}

@end
