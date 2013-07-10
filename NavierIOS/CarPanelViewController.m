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
#if 0
    NSArray *xibContents = [[NSBundle mainBundle] loadNibNamed:@"CarPanel1" owner:self options:nil];
    _carPanel1      = (CarPanel1UIView*)[xibContents lastObject];
    

     _carPanel1.frame = _contentView.frame;
    [_contentView addSubview:_carPanel1];
    

    NSDictionary *views = NSDictionaryOfVariableBindings(_carPanel1);
    
    [_carPanel1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [_contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_carPanel1]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    
    [_contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_carPanel1]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
#endif
    _redrawInterval = 0.5;
    _redrawTimer    = nil;
}

- (void)viewDidLoad
{
    [self initSelf];
    _carPanel1 = (CarPanel1UIView*)_contentView;
    [_carPanel1 start];
    
    [super viewDidLoad];

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
    [self dismissModalViewControllerAnimated:YES];
}
- (void)viewDidUnload {
    [self setContentView:nil];
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
