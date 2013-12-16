//
//  MarkerMenuFloatView.m
//  NavierIOS
//
//  Created by Coming on 12/7/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "MarkerMenuFloatView.h"


#include "Log.h"
@implementation MarkerMenuFloatView
{
    CGRect oriFrame;
    CGRect routeFrame;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self initSelf];
    }
    return self;
    
}

- (void)initSelf
{
    self.accessibilityLabel = @"markerMenuFloat";
    self.backgroundColor    = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.routeStartButton   = (UIButton*)[self viewWithTag:100];
    self.routeEndButton     = (UIButton*)[self viewWithTag:101];
    self.saveAsHomeButton   = (UIButton*)[self viewWithTag:102];
    self.saveAsOfficeButton = (UIButton*)[self viewWithTag:103];
    self.saveAsFavorButton  = (UIButton*)[self viewWithTag:104];
    
    [self.routeStartButton setTitle:[SystemManager getLanguageString:@"Route Start"] forState:UIControlStateNormal];
    [self.routeEndButton setTitle:[SystemManager getLanguageString:@"Route End"] forState:UIControlStateNormal];
    
    oriFrame    = self.frame;
    routeFrame  = self.frame;

    routeFrame.size.height = self.routeStartButton.frame.size.height;
}

-(void) showRouteButtonOnly
{
    self.frame = routeFrame;
}

-(void) show
{
    self.frame = oriFrame;
}

@end
