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
    BatteryLifeView *_batteryLifeView;
    float _courseAngleToPixelOffset;
    CGPoint _courseLabelOrigins[8];
    float _courseCenterNOffset;
}
@end

@implementation CarPanel1ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

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
    

    _clockTimerFormater = [[NSDateFormatter alloc] init];
    [_clockTimerFormater setDateFormat:@"HH:mm:ss"];
    
    _clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
  
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
    

    
    
    _batteryLifeView = [[BatteryLifeView alloc] initWithFrame:CGRectMake(18, 12, 49, 28)];
    [self.contentView addSubview:_batteryLifeView];
    
    self.color = [SystemConfig defaultColor];
	// Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    self.batteryLife    = [SystemManager getBatteryLife];
    self.networkStatus  = [SystemManager getNetworkStatus];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [SystemManager addDelegate:self];
    
    logfn();
    [[NSNotificationCenter defaultCenter]
     postNotificationName:UIDeviceBatteryLevelDidChangeNotification
     object:self];
    logfn();    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [SystemManager removeDelegate:self];
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
//    _courseCutLabel.textColor   = _color;
    _batteryLifeView.color      = _color;
    
    [_batteryImage      setImageTintColor:_color];
    [_gpsImage          setImageTintColor:_color];
    [_threeGImage       setImageTintColor:_color];
    [_courseFrameImage  setImageTintColor:_color];

    
    for (UILabel* l in _courseLabelArray)
    {
        l.textColor = _color;
    }
    
    [self placeCourseLabel];
}

-(void) setBatteryLife:(float)batteryLife
{
    if (batteryLife > 1)
        batteryLife = 1;
    
    if (batteryLife < 0)
        batteryLife = 0;
    
    _batteryLife            = batteryLife;
    _batteryLifeView.life   = _batteryLife;
    _batteryLifeLabel.text  = [NSString stringFromInt:(int)(_batteryLife*100)];
    logf(_batteryLifeView.life);
    
}

-(void) setGpsEnabled:(BOOL)gpsEnabled
{
    _gpsEnabled = gpsEnabled;
}

-(void) setNetworkStatus:(float)networkStatus
{
    
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
    [self setCourseLabel:nil];
    [self setBatteryLifeLabel:nil];
    [self setNetworkLabel:nil];
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

}

-(void) placeCourseLabel
{
    float space;
    float labelOffset;
    int i;
    CGSize labelSize;
    UILabel *label;
    CGRect labelFrame;
    CGRect screenRect;
    
    screenRect  = [SystemManager lanscapeScreenRect];
    labelSize   = _courseNLabel.frame.size;
    
    if (screenRect.size.width > 480)
    {
        self.courseLabelRect = CGRectMake(0, 5, 508, labelSize.height);
    }
    else
    {
        self.courseLabelRect = CGRectMake(0, 5, 508 - (568-480), labelSize.height);
    }
    
    /*
     * |-------------------------------- \\ -----|
     * |--Label--|--space--|------ \\ -----|
     * |----Label offset --|
     */
    space = ((self.courseLabelRect.size.width) - (labelSize.width*_courseLabelArray.count))/(_courseLabelArray.count);

    labelOffset = labelSize.width + space;
    _courseAngleToPixelOffset   = self.courseLabelRect.size.width/(2*M_PI);
    _courseCenterNOffset        = self.courseLabelRect.size.width/2 - labelSize.width/2 - space/2.0;
    for(i=0; i<_courseLabelArray.count; i++)
    {
        label       = (UILabel*) [_courseLabelArray objectAtIndex:i];
        labelFrame  = CGRectMake(
                                 self.courseLabelRect.origin.x + i*labelOffset + (space/2.0),
                                 self.courseLabelRect.origin.y,
                                 labelSize.width,
                                 labelSize.height);
        label.frame = labelFrame;
        _courseLabelOrigins[i] = labelFrame.origin;
    }
    
    self.courseCutLabel.frame = CGRectMake(-labelSize.width, labelFrame.origin.y, labelFrame.size.width, labelFrame.size.height);
    [self updateCourse];
    
}

-(void) updateCourse
{
    int i;
    UILabel *label;
    CGRect labelFrame;
    CGRect cutLabelFrame;
    
    float pixelToMove;
    
    cutLabelFrame   = _courseCutLabel.frame;
    pixelToMove     = _courseAngleToPixelOffset * _heading;
    

    for(i=0; i<_courseLabelArray.count; i++)
    {
        label       = (UILabel*) [_courseLabelArray objectAtIndex:i];
        labelFrame  = label.frame;
        labelFrame.origin = _courseLabelOrigins[i];
        labelFrame.origin.x += _courseCenterNOffset;
        labelFrame.origin.x -= pixelToMove;
        
        if ((labelFrame.origin.x + labelFrame.size.width) > self.courseLabelRect.origin.x + _courseLabelRect.size.width)
        {
            _courseCutLabel.text    = label.text;
            cutLabelFrame.origin.x  = labelFrame.origin.x;
            labelFrame.origin.x     -= _courseLabelRect.size.width;
        }
        else if (labelFrame.origin.x < 0)
        {
            _courseCutLabel.text    = label.text;
            cutLabelFrame.origin.x  = labelFrame.origin.x;
            labelFrame.origin.x     += _courseLabelRect.size.width;
        }

        label.frame = labelFrame;
    }
    
    _courseCutLabel.frame = cutLabelFrame;
 
}
-(void) updateUI
{
    _gpsEnabled = [SystemManager getGpsStatus] > 0;
    
    if (NO == _gpsEnabled)
    {
        _gpsImage.hidden = !_gpsImage.hidden;
    }
    else
    {
        _gpsImage.hidden = NO;
    }
    
    if (0 >= _networkStatus)
    {
        _threeGImage.hidden = !_threeGImage.hidden;
    }
    else
    {
        _threeGImage.hidden = NO;
    }
    
    [self updateClock];
    self.heading += 0.01;
    
    if (YES == [SystemConfig getBOOLValue:CONFIG_IS_DEBUG])
    {
        if ([SystemManager getThreeGStatus] > 0)
            self.networkLabel.text = @"3G";
        else if ([SystemManager getWifiStatus] > 0)
            self.networkLabel.text = @"Wifi";
        else
            self.networkLabel.text = @"None";
    }
}

-(void) setSpeed:(int)speed
{
    _speed = speed;
    _speedLabel.text = [NSString stringFromInt:_speed];
}

-(void) setHeading:(double)heading
{
    _heading = heading;
    
    while (_heading >= 2*M_PI)
    {
        _heading -= 2*M_PI;
    }
    
    while (_heading < 0)
    {
        _heading += 2*M_PI;
    }
    
    [self updateCourse];
    
}

-(void) locationUpdate:(CLLocationCoordinate2D) location speed:(int) speed distance:(int) distance heading:(double) heading
{
    self.speed      = speed;
    self.heading    = heading;
    
}

-(void) lostLocationUpdate
{
    
}

-(void) networkStatusChangeWifi:(float) wifiStatus threeG:(float) threeGStatus
{
    self.networkStatus = wifiStatus + threeGStatus;
}


-(void) batteryStatusChange:(float) status
{
    self.batteryLife = status;
}

@end
