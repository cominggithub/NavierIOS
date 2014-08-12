//
//  BuyCollectionViewController.m
//  NavierIOS
//
//  Created by Coming on 8/3/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "BuyCollectionViewController.h"
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
    NSMutableArray *iapImages;
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
    
    iapImages = [@[@"buy1.png",
                 @"buy2.png",
                 @"buy3.png",
                 @"buy4.png",
                 @"buy5.png",] mutableCopy];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    // 隱藏 Navigation Bar
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    [GoogleUtil sendScreenView:@"Buy View"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // 顯示 Navigation Bar
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return iapImages.count;
}

// 設定要顯示 cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"iapImageCell";
    IAPImageCell *iapImageCell = (IAPImageCell*) [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    iapImageCell.backgroundColor = [UIColor whiteColor];
//    logO(iapImageCell);
//    logO(iapImageCell.imageView);
    iapImageCell.imageView.image = [UIImage imageNamed:[iapImages objectAtIndex:indexPath.row]];

//    iapImageCell.imageView.image = [UIImage imageNamed:@"buy1"];
    
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
