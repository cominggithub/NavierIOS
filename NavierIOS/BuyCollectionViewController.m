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
    NSDictionary *iapImages;
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

    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:@"Buy Collection"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    iapImages = [[NSDictionary alloc] initWithObjects:[@[@"buy1.png", @"buy2.png", @"buy3.png", @"buy4.png"] mutableCopy]
                                              forKeys:[@[IAP_NO_AD_STORE_USER_PLACE, IAP_CAR_PANEL_2, IAP_CAR_PANEL_3, IAP_CAR_PANEL_4] mutableCopy]];
    // Do any additional setup after loading the view.
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
    
    if (FALSE == [SystemConfig getBoolValue:CONFIG_IAP_IS_ADVANCED_VERSION])
        [self addIapItem:IAP_NO_AD_STORE_USER_PLACE];
    
    if (FALSE == [SystemConfig getBoolValue:CONFIG_IAP_IS_CAR_PANEL_2])
        [self addIapItem:IAP_CAR_PANEL_2];

    if (FALSE == [SystemConfig getBoolValue:CONFIG_IAP_IS_CAR_PANEL_3])
        [self addIapItem:IAP_CAR_PANEL_3];
    
    if (FALSE == [SystemConfig getBoolValue:CONFIG_IAP_IS_CAR_PANEL_4])
        [self addIapItem:IAP_CAR_PANEL_4];
    
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
    iapImageCell.priceLabel.text = product.localizedPrice;
    
    return iapImageCell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
