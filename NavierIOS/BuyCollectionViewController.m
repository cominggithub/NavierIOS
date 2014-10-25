//
//  BuyCollectionViewController.m
//  NavierIOS
//
//  Created by Coming on 8/3/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "BuyCollectionViewController.h"
#import <NaviUtil/SKProduct+category.h>
#import "IAPImageCell.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import <NaviUtil/NaviUtil.h>

#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG TRUE
#else
#define FILE_DEBUG TRUE
#endif

#include "Log.h"



@interface BuyCollectionViewController ()
{
    UIImage *selectedImage;
    NSMutableArray *iapItems;
    NSMutableDictionary *buyButtons;
    NSDictionary *iapImages;
    UIAlertView  *alert;
    BOOL isRestoreAlertPrompted;
}

@end

@implementation BuyCollectionViewController

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
    [super viewDidLoad];

    self.buying     = FALSE;
    id tracker      = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:@"Buy Collection"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    iapImages = [[NSDictionary alloc] initWithObjects:[@[@"advanced_version", @"carPanel2", @"carPanel3", @"carPanel4"] mutableCopy]
                                              forKeys:[@[IAP_NO_AD_STORE_USER_PLACE, IAP_CAR_PANEL_2, IAP_CAR_PANEL_3, IAP_CAR_PANEL_4] mutableCopy]];
    
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main"]];
    buyButtons  = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    isRestoreAlertPrompted = FALSE;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:IAP_EVENT_IAP_STATUS_RETRIEVED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:IAP_EVENT_IAP_STATUS_RETRIEVE_FAIL
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:IAP_EVENT_TRANSACTION_RESTORE
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:IAP_EVENT_TRANSACTION_FAILED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:IAP_EVENT_TRANSACTION_COMPLETE
                                               object:nil];
    
    // Do any additional setup after loading the view.
}

-(void) dismiss
{
    [self.navigationController popViewControllerAnimated:TRUE];
}
-(void) addIapItem:(NSString*) key
{
    SKProduct *product;
    product = [NavierHUDIAPHelper productByKey:key];
    if (nil != product)
        [iapItems addObject:product];
}

-(void) loadIapItem
{
    iapItems = [[NSMutableArray alloc] initWithCapacity:4];

    if (NO == [NavierHUDIAPHelper hasUnbroughtIap])
        [self dismiss];
    
    if (FALSE == [SystemConfig getBoolValue:CONFIG_IAP_IS_ADVANCED_VERSION])
        [self addIapItem:IAP_NO_AD_STORE_USER_PLACE];
    
    if (FALSE == [SystemConfig getBoolValue:CONFIG_IAP_IS_CAR_PANEL_2])
        [self addIapItem:IAP_CAR_PANEL_2];

    if (FALSE == [SystemConfig getBoolValue:CONFIG_IAP_IS_CAR_PANEL_3])
        [self addIapItem:IAP_CAR_PANEL_3];
    
    // car panel 4 is not available for screen size 480x320
    if ([SystemManager lanscapeScreenRect].size.width >= 568)
    {
        if (FALSE == [SystemConfig getBoolValue:CONFIG_IAP_IS_CAR_PANEL_4])
            [self addIapItem:IAP_CAR_PANEL_4];
    }
    
    [self.collectionView reloadData];

}

-(UIImage*) getImageByIapKey:(NSString*) key
{
    return [UIImage imageNamed:[iapImages objectForKey:key]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:FALSE animated:YES];

    [self loadIapItem];
    [GoogleUtil sendScreenView:@"Buy View"];
}

- (void)viewWillDisappear:(BOOL)animated
{

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return iapItems.count;
}

// 設定要顯示 cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"iapImageCell";
    SKProduct *product;
    product = [iapItems objectAtIndex:indexPath.row];
    IAPImageCell *iapImageCell = (IAPImageCell*) [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    iapImageCell.backgroundColor = [UIColor whiteColor];
    iapImageCell.imageView.image = [self getImageByIapKey:product.productIdentifier];
    iapImageCell.priceLabel.text = [NSString stringWithFormat:@"%@  %@", product.localizedTitle, product.localizedPrice];
    [iapImageCell.buyButton setTitle: [SystemManager getLanguageString:@"Buy"]
                            forState:UIControlStateNormal];
    [iapImageCell.restoreButton setTitle:[SystemManager getLanguageString:iapImageCell.restoreButton.titleLabel.text]
                                forState:UIControlStateNormal];

    [iapImageCell.restoreButton addTarget:self action:@selector(pressRestoreButton:)    forControlEvents:UIControlEventTouchUpInside];
    [iapImageCell.buyButton     addTarget:self action:@selector(pressBuyButton:)        forControlEvents:UIControlEventTouchUpInside];

    iapImageCell.buyButton.accessibilityLabel = product.productIdentifier;
    
    if ([product.productIdentifier isEqualToString:IAP_NO_AD_STORE_USER_PLACE])
    {
        iapImageCell.descriptionTextView.layer.borderWidth = 3.0f;
        iapImageCell.descriptionTextView.layer.borderColor = [[UIColor redColor] CGColor];
        iapImageCell.descriptionTextView.layer.cornerRadius = 5;
        iapImageCell.descriptionTextView.clipsToBounds = YES;
        
        iapImageCell.descriptionTextView.hidden = NO;
        iapImageCell.descriptionTextView.text = product.localizedDescription;
    }
    else
    {
        iapImageCell.descriptionTextView.hidden = YES;
    }


    return iapImageCell;
}


-(void)pressRestoreButton:(UIButton*)sender
{
    self.buying = TRUE;
    [NavierHUDIAPHelper restorePurchasedProduct];
}

-(void)pressBuyButton:(UIButton*)sender
{
    SKProduct* product;
    mlogDebug(@"buy %@", sender.accessibilityLabel);
    product = [NavierHUDIAPHelper productByKey:sender.accessibilityLabel];
    if (nil != product)
    {
        self.buying = TRUE;
        [NavierHUDIAPHelper buyProduct:product];
    }
}


- (void) receiveNotification:(NSNotification *) notification
{
    NSString* identifier;
    
    self.buying = FALSE;
    identifier  = notification.object;

    if ([notification.name isEqualToString:IAP_EVENT_TRANSACTION_COMPLETE])
    {
        if ([identifier isEqualToString:IAP_NO_AD_STORE_USER_PLACE])
        {
            [self showAlertTitle:[SystemManager getLanguageString:@"Purchase successfully"]
                         message:[NSString stringWithFormat:
                                [SystemManager getLanguageString:@"Thanks! %@ now is upgraded to Advanced version"], @"Naiver HUD"]];
            
        }
        else
        {
            [self showAlertTitle:[SystemManager getLanguageString:@"Purchase successfully"]
                         message:[NSString stringWithFormat:@""]];
        }
        
    }
    else if ([notification.name isEqualToString:IAP_EVENT_TRANSACTION_RESTORE] && FALSE == isRestoreAlertPrompted)
    {

        
        if ([identifier isEqualToString:IAP_NO_AD_STORE_USER_PLACE])
        {
            [self showAlertTitle:[SystemManager getLanguageString:@"Purchase successfully"]
                         message:[NSString stringWithFormat:
                                  [SystemManager getLanguageString:@"Thanks! %@ now is upgraded to Advanced version"], @"Naiver HUD"]];
            
        }
        else
        {
            [self showAlertTitle:[SystemManager getLanguageString:@"Purchase successful"]
                         message:[NSString stringWithFormat:@""]];
        }
        
        isRestoreAlertPrompted = TRUE;
    }
    else if ([notification.name isEqualToString:IAP_EVENT_TRANSACTION_FAILED])
    {
        [self showAlertTitle:[SystemManager getLanguageString:@"Purchase failed"]
                     message:[NSString stringWithFormat:@""]];
    }

    [self loadIapItem];
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
}

@end
