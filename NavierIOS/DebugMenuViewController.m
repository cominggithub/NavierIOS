//
//  DebugMenuViewController.m
//  NavierIOS
//
//  Created by Coming on 13/6/22.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "DebugMenuViewController.h"

@interface DebugMenuViewController ()
{
    UIView *debugMenuView;
    UIButton *debugMenuLogoButton;
    UISwitch *debugMenuIsDebugSwitch;
    UISwitch *debugMenuIsAdSwitch;
    UISwitch *debugMenuIsDebugRouteDrawSwitch;
    UISwitch *debugMenuIsManualPlaceSwitch;
    UISegmentedControl *debugMenuLanguageSegmentControl;
    UIPickerView *debugMenuPlacePickerView;
    
    
}
@end

@implementation DebugMenuViewController

-(void) addDebugMenu
{

    NSArray *xibContents                = [[NSBundle mainBundle] loadNibNamed:@"DebugMenu" owner:self options:nil];
    debugMenuView                       = [xibContents lastObject];
    debugMenuLogoButton                 = (UIButton *)          [debugMenuView viewWithTag:1  ];
    debugMenuIsDebugSwitch              = (UISwitch *)          [debugMenuView viewWithTag:101];
    debugMenuIsAdSwitch                 = (UISwitch *)          [debugMenuView viewWithTag:102];
    debugMenuIsDebugRouteDrawSwitch     = (UISwitch *)          [debugMenuView viewWithTag:103];
    debugMenuLanguageSegmentControl     = (UISegmentedControl *)[debugMenuView viewWithTag:104];
    debugMenuIsManualPlaceSwitch        = (UISwitch *)          [debugMenuView viewWithTag:105];
    debugMenuPlacePickerView            = (UIPickerView *)      [debugMenuView viewWithTag:106];
    
    [debugMenuLogoButton addTarget:self
                            action:@selector(pressLogoButton:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [debugMenuIsDebugSwitch             addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];
    [debugMenuIsAdSwitch                addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];
    [debugMenuIsDebugRouteDrawSwitch    addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];
    [debugMenuLanguageSegmentControl    addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];
    [debugMenuIsManualPlaceSwitch       addTarget:self action:@selector(uiValueChanged:) forControlEvents:UIControlEventValueChanged];

    debugMenuPlacePickerView.delegate    = self;
    debugMenuPlacePickerView.dataSource  = self;
    
    debugMenuView.frame = self.view.frame;
    NSDictionary *views = NSDictionaryOfVariableBindings(debugMenuView);
    
    [self.view addSubview:debugMenuView];
    
    [debugMenuView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[debugMenuView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];


    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[debugMenuView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    

    
        
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) pressLogoButton:(id)sender
{
    logfn();
    [self dismissModalViewControllerAnimated:YES];
}


-(void) saveConfigFromUI
{

    [LocationManager setCurrentManualPlace:[LocationManager getManualPlaceByIndex:[debugMenuPlacePickerView selectedRowInComponent:0]]];
    [SystemConfig setIsDebug:debugMenuIsDebugSwitch.on];
    [SystemConfig setIsAd:debugMenuIsAdSwitch.on];
    [SystemConfig setIsDebugRouteDraw:debugMenuIsDebugRouteDrawSwitch.on];
    [SystemConfig setIsManualPlace:debugMenuIsManualPlaceSwitch.on];

    
}

-(void) updateUIFromConfig
{
    debugMenuIsDebugSwitch.on           = SystemConfig.isDebug;
    debugMenuIsAdSwitch.on              = SystemConfig.isAd;
    debugMenuIsDebugRouteDrawSwitch.on  = SystemConfig.isDebugRouteDraw;
    debugMenuIsManualPlaceSwitch.on     = SystemConfig.isManualPlace;
    
}

-(void) uiValueChanged:(id) sender
{
    [self saveConfigFromUI];
}

-(void) viewDidUnload {
    
    [self setScrollView:nil];
    [super viewDidUnload];
}


#pragma PicketView
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
    return ((Place*)[LocationManager getManualPlaceByIndex:row]).name;
}


@end
