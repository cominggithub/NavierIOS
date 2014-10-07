//
//  SelectCarPanelViewController.m
//  NavierIOS
//
//  Created by Coming on 8/17/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "SelectCarPanelViewController.h"
#import <NaviUtil/NaviUtil.h>
#import "CarPanelImageCell.h"


#if DEBUG
#define FILE_DEBUG FALSE
#elif RELEASE_TEST
#define FILE_DEBUG FALSE
#else
#define FILE_DEBUG FALSE
#endif

#include "Log.h"


@interface SelectCarPanelViewController ()
{
    UIImage *selectedImage;
    NSMutableArray *iapImages;
}

@end

@implementation SelectCarPanelViewController

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
    
    [GoogleUtil sendScreenView:@"Car Panel Selection"];
//    self.collectionView.backgroundColor    = [UIColor colorWithRed:6.0/255.0 green:60.0/255.0 blue:74.0/255.0 alpha:1];
//    self.view.backgroundColor   = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_main"]];
    
    iapImages = [@[@"carPanel1",
                   @"carPanel2",
                   @"carPanel3",
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
    static NSString *identifier = @"carPanelImageCell";
    CarPanelImageCell *carPanelImageCell = (CarPanelImageCell*) [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
//    carPanelImageCell.backgroundColor = [UIColor colorWithRed:6.0/255.0 green:60.0/255.0 blue:74.0/255.0 alpha:0.8];
    carPanelImageCell.backgroundColor = [UIColor colorWithRed:255/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.15];
    carPanelImageCell.imageView.image = [UIImage imageNamed:[iapImages objectAtIndex:indexPath.row]];
    return carPanelImageCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    [self performSegueWithIdentifier:@"carPanel3Segue" sender:self];
//    return;
    if (indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"carPanel1Segue" sender:self];
    }
    else if (indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"carPanel2Segue" sender:self];
    }
    else if (indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"carPanel3Segue" sender:self];
    }
    else if (indexPath.row == 3)
    {
        [self performSegueWithIdentifier:@"carPanel4Segue" sender:self];
    }
}

@end
