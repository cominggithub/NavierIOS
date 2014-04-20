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
#import <NaviUtil/UIImage+category.h>
#import <NaviUtil/IAPHelper.h>
#import <GoogleMaps/GoogleMaps.h>

#define FILE_DEBUG FALSE
#include "Log.h"

@interface BuyUIViewController ()

@end

@implementation BuyUIViewController
{
    SKProduct *product;
    UIAlertView *alert;
    GMSMapView *mapView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initSelf];
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

- (id) init
{
    self = [super init];
    if (self) {
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
    alert   = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.buyButton setTitle:[SystemManager getLanguageString:self.buyButton.titleLabel.text] forState:UIControlStateNormal];
    

    self.restoreIapItemButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.restoreIapItemButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.restoreIapItemButton setTitle:[SystemManager getLanguageString:self.restoreIapItemButton.titleLabel.text]
                               forState:UIControlStateNormal];

    self.naviLeftButton.imageView.image = [self.naviLeftButton.imageView.image imageTintedWithColor:self.naviLeftButton.tintColor];
    [self.backButton setTitle:[SystemManager getLanguageString:self.backButton.titleLabel.text] forState:UIControlStateNormal];
    
    self.purchasePanel.backgroundColor     = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.purchasePanel.layer.borderColor   = [UIColor grayColor].CGColor;
    self.purchasePanel.layer.borderWidth   = 1;
    self.purchasePanel.layer.cornerRadius  = 2.0f;
    self.purchasePanel.layer.masksToBounds = TRUE;
    
    logO([SystemManager getSystemLanguage]);
    
    if (480 == SystemManager.lanscapeScreenRect.size.width)
    {

        if ([[SystemManager getSystemLanguage] isEqualToString:@"zh-Hant"])
        {
            self.routePlaceView.hidden = YES;
            self.bgImageView.image = [UIImage imageNamed:@"IAP_NoAdStoreUserPlace_bg_35_tw"];
        }
        else
        {
            self.bgImageView.image = [UIImage imageNamed:@"IAP_NoAdStoreUserPlace_bg_35"];
        }
    }
    else
    {
        if ([[SystemManager getSystemLanguage] isEqualToString:@"zh-Hant"])
        {
            self.routePlaceView.hidden = YES;
            self.bgImageView.image = [UIImage imageNamed:@"IAP_NoAdStoreUserPlace_bg_4_tw"];
        }
        else
        {
            self.bgImageView.image = [UIImage imageNamed:@"IAP_NoAdStoreUserPlace_bg_4"];
        }
    }
    
    
    /* configure routePlaceView */
    self.routePlaceView.backgroundColor     = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.routePlaceView.layer.borderColor   = [UIColor grayColor].CGColor;
    self.routePlaceView.layer.borderWidth   = 1;
    self.routePlaceView.layer.cornerRadius  = 2.0f;
    self.routePlaceView.layer.masksToBounds = TRUE;
    self.routePlaceView.hidden              = FALSE;
    
    /* configure route Label */
    self.fromLabel.text         = [NSString stringWithFormat:@"%@:", [SystemManager getLanguageString:self.fromLabel.text]];
    self.toLabel.text           = [NSString stringWithFormat:@"%@:", [SystemManager getLanguageString:self.toLabel.text]];
    self.fromPlaceLabel.text    = [SystemManager getLanguageString:self.fromPlaceLabel.text];
    self.toPlaceLabel.text      = [SystemManager getLanguageString:self.toPlaceLabel.text];
    
	// Do any additional setup after loading the view.
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:23.845650
                                                            longitude:120.893555
                                                                 zoom:6];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.frame            = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    Place* currentPlace                = [LocationManager currentPlace];

    mapView.camera = [GMSCameraPosition cameraWithLatitude:currentPlace.coordinate.latitude
                                                  longitude:currentPlace.coordinate.longitude
                                                       zoom:12
                                                    bearing:10.f
                                               viewingAngle:10];

    [mapView addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    [mapView.settings setAllGesturesEnabled:FALSE];

    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView.myLocationEnabled = YES;
    });
    
    [self.contentView insertSubview:mapView atIndex:1];
}

-(void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    CLLocation *location;
    location        = [change objectForKey:NSKeyValueChangeNewKey];
    mapView.camera  = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:12];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.naviLeftButton.imageView.image = [self.naviLeftButton.imageView.image imageTintedWithColor:self.naviLeftButton.tintColor];
    [self updateProduct];
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
#if FILE_DEBUG == TRUE

        mlogDebug(@"%@: %@", IAPHelperProductPurchasedNotification, productIdentifier);
#endif
        if ([productIdentifier isEqualToString:@"com.coming.NavierHUD.Iap.AdvancedVersion"])
        {
            mlogDebug(@"%@: %@", IAPHelperProductPurchasedNotification, productIdentifier);
            [self showAlertTitle:[SystemManager getLanguageString:@"Purchase successfully"]
                         message:[SystemManager getLanguageString:@"Thanks! Navier HUD now is upgradded to Advanced version"]];
             
        }
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

    if([product.price floatValue] == 0)
    {
        self.productPrice.text      = [SystemManager getLanguageString:@"Free"];
    }
    else
    {
        self.productPrice.text      = product.localizedPrice;
    }

}


- (IBAction)pressBuyButton:(id)sender
{
    if (nil != product)
    {
        [NavierHUDIAPHelper buyProduct:product];
    }
}

- (IBAction)pressBackButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)pressRestorePurchasedItemButton:(id)sender
{
    [NavierHUDIAPHelper restorePurchasedProduct];
}

-(void) showAlertTitle:(NSString*) title message:(NSString*) message
{
    if (nil == alert)
    {
        alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:[SystemManager getLanguageString:@"OK"] otherButtonTitles:nil,nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    alert = nil;
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
