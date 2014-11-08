//
//  ShareViewController.m
//  NavierIOS
//
//  Created by Coming on 8/17/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "ShareViewController.h"
#import <NaviUtil/NaviUtil.h>

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"


@interface ShareViewController ()

@end

@implementation ShareViewController

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
    self.view.backgroundColor           =[[UIColor blackColor] colorWithAlphaComponent:.0];
    self.popUpView.backgroundColor      = [UIColor colorWithRed:6.0/255.0 green:60.0/255.0 blue:74.0/255.0 alpha:1];
    self.popUpView.layer.borderColor    = [UIColor grayColor].CGColor;
    self.popUpView.layer.cornerRadius   = 15;
    self.popUpView.layer.shadowOpacity  = 0.8;
    self.popUpView.layer.shadowOffset   = CGSizeMake(0.0f, 0.0f);
    
    self.titleLabel.text = [SystemManager getLanguageString:@"Share Navier HUD to Your Friends"];
    [self.closeButton setTitle:[SystemManager getLanguageString:self.closeButton.titleLabel.text]
                      forState:UIControlStateNormal];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)showAnimate
{
    self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.view.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        self.view.alpha = 1;
        self.view.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
}


- (IBAction)pressClose:(id)sender
{
    [self removeAnimate];
}

- (IBAction)pressShareOnFB:(id)sender {
    [FBUtil shareAppStoreLink];
}

- (IBAction)pressShareOnTwitter:(id)sender {
    
//    [TwitterUtil shareAppStoreLink:[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]];
    [TwitterUtil shareAppStoreLink];
}

- (void)removeAnimate
{
    [UIView animateWithDuration:.25 animations:^{
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.view removeFromSuperview];
        }
    }];
}

- (void)showInView:(UIView *)aView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [aView addSubview:self.view];
        self.view.center = aView.center;
        [self showAnimate];
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
