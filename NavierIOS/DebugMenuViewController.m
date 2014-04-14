//
//  DebugMenuViewController.m
//  NavierIOS
//
//  Created by Coming on 13/6/22.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "DebugMenuViewController.h"

#define FILE_DEBUG FALSE
#include <NaviUtil/Log.h>

@interface DebugMenuViewController ()
{
    UIView *_debugMenuView;
    UIButton *_debugMenuLogoButton;
    UISwitch *_debugMenuIsDebugSwitch;
    UISwitch *_debugMenuIsAdSwitch;
    UISwitch *_debugMenuIsUserPlaceSwitch;
    UISwitch *_debugMenuIsDebugRouteDrawSwitch;
    UISwitch *_debugMenuIsManualPlaceSwitch;
    UISwitch *_debugMenuIsSpeechSwitch;
    UISwitch *_debugMenuIsLocationSimulatorSwitch;
    UISwitch *_debugMenuIsTrackFileSwitch;
    UISwitch *_debugMenuIsSimulateLocationLostSwitch;
    UISwitch *_debugMenuIsSimulateCarMovementSwitch;
    UISegmentedControl *_debugMenuLanguageSegmentControl;
    UIPickerView *_debugMenuPlacePickerView;
    
    UIScrollView *_debugMenuScrollView;
    LocationSimulator *locationSimulator;
    
}
@end

@implementation DebugMenuViewController

-(void) addDebugMenu
{

    NSArray *xibContents                    = [[NSBundle mainBundle] loadNibNamed:@"DebugMenu" owner:self options:nil];
    
    _debugMenuView                          = [xibContents lastObject];
    _debugMenuLogoButton                    = (UIButton *)          [_debugMenuView viewWithTag:1  ];
    _debugMenuIsDebugSwitch                 = (UISwitch *)          [_debugMenuView viewWithTag:101];
    _debugMenuIsAdSwitch                    = (UISwitch *)          [_debugMenuView viewWithTag:102];
    _debugMenuIsDebugRouteDrawSwitch        = (UISwitch *)          [_debugMenuView viewWithTag:103];
    _debugMenuLanguageSegmentControl        = (UISegmentedControl *)[_debugMenuView viewWithTag:104];
    _debugMenuIsManualPlaceSwitch           = (UISwitch *)          [_debugMenuView viewWithTag:105];
    _debugMenuPlacePickerView               = (UIPickerView *)      [_debugMenuView viewWithTag:106];
    _debugMenuIsSpeechSwitch                = (UISwitch *)          [_debugMenuView viewWithTag:107];
    _debugMenuIsLocationSimulatorSwitch     = (UISwitch *)          [_debugMenuView viewWithTag:108];
    _debugMenuIsTrackFileSwitch             = (UISwitch *)          [_debugMenuView viewWithTag:109];
    _debugMenuIsUserPlaceSwitch             = (UISwitch *)          [_debugMenuView viewWithTag:110];
    _debugMenuIsSimulateLocationLostSwitch  = (UISwitch *)          [_debugMenuView viewWithTag:111];
    _debugMenuIsSimulateCarMovementSwitch   = (UISwitch *)          [_debugMenuView viewWithTag:112];
    _debugMenuScrollView                    = (UIScrollView *)      [_debugMenuView viewWithTag:200];

    [_debugMenuScrollView setContentSize:CGSizeMake(468, 1000)];
    
    [_debugMenuLogoButton addTarget:self
                            action:@selector(pressLogoButton:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [_debugMenuIsDebugSwitch                    addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_debugMenuIsAdSwitch                       addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_debugMenuIsDebugRouteDrawSwitch           addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_debugMenuLanguageSegmentControl           addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_debugMenuIsManualPlaceSwitch              addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_debugMenuIsSpeechSwitch                   addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_debugMenuIsLocationSimulatorSwitch        addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_debugMenuIsTrackFileSwitch                addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_debugMenuIsUserPlaceSwitch                addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_debugMenuIsSimulateLocationLostSwitch     addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_debugMenuIsSimulateCarMovementSwitch      addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];

    _debugMenuPlacePickerView.delegate    = self;
    _debugMenuPlacePickerView.dataSource  = self;
    
//    _debugMenuView.frame = self.view.frame;
    
    [self.view addSubview:_debugMenuView];
        
}
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
    [self addDebugMenu];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [self updateUIFromConfig];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) pressLogoButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pressClearConfigButton:(id)sender
{
    [User clearConfig];
    [User save];
}

- (IBAction)pressDebugConfigButton:(id)sender
{
    [User createDebugConfig];
    [User save];
}


-(void) saveConfigFromUI
{

    [LocationManager setCurrentManualPlace:[LocationManager getManualPlaceByIndex:(int)[_debugMenuPlacePickerView selectedRowInComponent:0]]];

    [SysConfig setValue:CONFIG_H_IS_DEBUG BOOL:_debugMenuIsDebugSwitch.on];
    [SysConfig setValue:CONFIG_H_IS_AD BOOL:_debugMenuIsAdSwitch.on];
    [SysConfig setValue:CONFIG_H_IS_DEBUG_ROUTE_DRAW BOOL:_debugMenuIsDebugRouteDrawSwitch.on];
    [SysConfig setValue:CONFIG_H_IS_MANUAL_PLACE BOOL:_debugMenuIsManualPlaceSwitch.on];
    [SysConfig setValue:CONFIG_IS_SPEECH BOOL:_debugMenuIsSpeechSwitch.on];
    [SysConfig setValue:CONFIG_H_IS_LOCATION_SIMULATOR BOOL:_debugMenuIsLocationSimulatorSwitch.on];
    [SysConfig setValue:CONFIG_IS_TRACK_FILE BOOL:_debugMenuIsTrackFileSwitch.on];
    [SysConfig setValue:CONFIG_H_IS_USER_PLACE BOOL:_debugMenuIsUserPlaceSwitch.on];
    [SysConfig setValue:CONFIG_H_IS_SIMULATE_LOCATION_LOST BOOL:_debugMenuIsSimulateLocationLostSwitch.on];
    [SysConfig setValue:CONFIG_H_IS_SIMULATE_CAR_MOVEMENT BOOL:_debugMenuIsSimulateCarMovementSwitch.on];

}

-(void) updateUIFromConfig
{
    _debugMenuIsDebugSwitch.on                  = [SysConfig getBoolValue:CONFIG_H_IS_DEBUG];
    _debugMenuIsAdSwitch.on                     = [SysConfig getBoolValue:CONFIG_H_IS_AD];
    _debugMenuIsDebugRouteDrawSwitch.on         = [SysConfig getBoolValue:CONFIG_H_IS_DEBUG_ROUTE_DRAW];
    _debugMenuIsManualPlaceSwitch.on            = [SysConfig getBoolValue:CONFIG_H_IS_MANUAL_PLACE];
    _debugMenuIsSpeechSwitch.on                 = [SysConfig getBoolValue:CONFIG_IS_SPEECH];
    _debugMenuIsLocationSimulatorSwitch.on      = [SysConfig getBoolValue:CONFIG_H_IS_LOCATION_SIMULATOR];
    _debugMenuIsTrackFileSwitch.on              = [SysConfig getBoolValue:CONFIG_IS_TRACK_FILE];
    _debugMenuIsUserPlaceSwitch.on              = [SysConfig getBoolValue:CONFIG_H_IS_USER_PLACE];
    _debugMenuIsSimulateLocationLostSwitch.on   = [SysConfig getBoolValue:CONFIG_H_IS_SIMULATE_LOCATION_LOST];
    _debugMenuIsSimulateCarMovementSwitch.on    = [SysConfig getBoolValue:CONFIG_H_IS_SIMULATE_CAR_MOVEMENT];
    
}

-(void) uiValueChanged:(id) sender
{
    [self saveConfigFromUI];
    if (TRUE == [SysConfig getBoolValue:CONFIG_H_IS_SIMULATE_CAR_MOVEMENT])
    {
        [LocationManager setLocationUpdateType:kLocationManagerLocationUpdateType_File];
        [LocationManager startLocationSimulation];
    }
    else
    {
        [LocationManager stopLocationSimulation];
    }
}

-(void) viewDidUnload
{
    
    [super viewDidUnload];
}


#pragma mark - PicketView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self saveConfigFromUI];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [LocationManager getManualPlaceCount];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return ((Place*)[LocationManager getManualPlaceByIndex:(int)row]).name;
}


@end
