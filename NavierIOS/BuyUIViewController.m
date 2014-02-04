//
//  BuyAllViewController.m
//  NavierIOS
//
//  Created by Coming on 8/3/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "BuyUIViewController.h"
#import <NaviUtil/NaviUtil.h>
#import <NaviUtil/SKProduct+category.h>

#include "Log.h"

@interface BuyUIViewController ()

@end

@implementation BuyUIViewController
{
    SKProduct *product;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initSelf];
    }
    
    return self;
}

- (void)initSelf
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:IAPHelperProductUpdatedNotification
                                               object:nil];
    

    product = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.buyButton setTitle:[SystemManager getLanguageString:self.buyButton.titleLabel.text] forState:UIControlStateNormal];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScroller:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateProduct];
}

- (IBAction)pressLogoButton:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:IAPHelperProductPurchasedNotification])
    {
        NSString* productIdentifier = [notification object];
        NSLog (@"%@: %@", IAPHelperProductPurchasedNotification, productIdentifier);
    }
    else if ([[notification name] isEqualToString:IAPHelperProductUpdatedNotification])
    {
        [self updateProduct];
    }
}

- (void) updateProduct
{
    product                         = [NavierHUDIAPHelper productByKey:IAP_NO_AD_STORE_USER_PLACE];
    self.productTitle.text          = product.localizedTitle;
    self.productDescription.text    = product.localizedDescription;
    self.productPrice.text          = product.localizedPrice;

}


- (IBAction)pressBuyButton:(id)sender
{
    logfn();
    if (nil != product)
    {
        logfn();
        [NavierHUDIAPHelper buyProduct:product];
    }
}

@end
