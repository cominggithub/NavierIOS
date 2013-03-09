//
//  ViewController.m
//  NavierIOS
//
//  Created by Coming on 13/2/25.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* for orientation in iOS 5.0, 5.1 
 * must set it for evern UIViewController?
 */
 
 
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (IBAction)pressPlace:(id)sender
{
    int i;
    NSString *fileName = @"/Users/Coming/ios/google/place_tainan1_senior.json";
    NSArray* places = [NSArray arrayWithArray:[Place parseJson:fileName]];
    
    for(i=0; i<places.count; i++)
    {
        printf("%s\n", [[[places objectAtIndex:i] description] UTF8String]);
    }

    
    // This function can be called with any number (even 0) or type of objects, as long as you terminate it with "nil":
    logWarning(@"foo", [NSNumber numberWithInt:4], @"bar", nil);
    logInfo(@"foo", [NSNumber numberWithInt:4], @"bar", nil);
    logDebug(@"foo", [NSNumber numberWithInt:4], @"bar", nil);
    logError(@"foo", [NSNumber numberWithInt:4], @"bar", nil);
    
}

- (IBAction)pressRoute:(id)sender
{
    CLLocationCoordinate2D ncku     = CLLocationCoordinate2DMake(22.996501,120.216678);
    CLLocationCoordinate2D accton   = CLLocationCoordinate2DMake(23.099313,120.284371);
    
    [NaviQueryManager planRouteStartLocation:ncku EndLocation:accton];
}
@end
