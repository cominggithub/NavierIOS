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
#import "CarPanelSelector.h"
#import "BuyCollectionViewController.h"


#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG FALSE
#else
#define FILE_DEBUG FALSE
#endif

#include "Log.h"


@interface SelectCarPanelViewController ()
{
    UIImage *selectedImage;
    CarPanelSelector* carPanelSelector;
    BuyCollectionViewController *buyCollectionViewController;
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

    UIStoryboard *storyboard          = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    buyCollectionViewController       = (BuyCollectionViewController *)[storyboard instantiateViewControllerWithIdentifier:NSStringFromClass ([BuyCollectionViewController class])];
    carPanelSelector = [[CarPanelSelector alloc] init];
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
    [self.collectionView setContentOffset:CGPointZero animated:YES];
    

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
    return carPanelSelector.iapImages.count;
}

// 設定要顯示 cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"carPanelImageCell";
    CarPanelImageCell *carPanelImageCell = (CarPanelImageCell*) [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
//    carPanelImageCell.backgroundColor = [UIColor colorWithRed:6.0/255.0 green:60.0/255.0 blue:74.0/255.0 alpha:0.8];
    carPanelImageCell.backgroundColor       = [UIColor colorWithRed:255/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.15];
    carPanelImageCell.imageView.image       = [UIImage imageNamed:[carPanelSelector.iapImages objectAtIndex:indexPath.row]];
    return carPanelImageCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* selectedCarPanel;
    selectedCarPanel = [carPanelSelector.iapImages objectAtIndex:indexPath.row];

    [carPanelSelector useCarPanel:selectedCarPanel];
    
    if ([selectedCarPanel isEqualToString:CAR_PANEL_1] == TRUE)
    {
        [self performSegueWithIdentifier:@"carPanel1Segue" sender:self];
    }
    else if ([selectedCarPanel isEqualToString:CAR_PANEL_2] == TRUE)
    {
        if([SystemConfig getBoolValue:CONFIG_IAP_IS_CAR_PANEL_2])
        {
            [self performSegueWithIdentifier:@"carPanel2Segue" sender:self];
        }
        else
        {
            [self showIap];
        }
    }
    else if ([selectedCarPanel isEqualToString:CAR_PANEL_3] == TRUE)
    {
        if([SystemConfig getBoolValue:CONFIG_IAP_IS_CAR_PANEL_3])
        {
            [self performSegueWithIdentifier:@"carPanel3Segue" sender:self];
        }
        else
        {
            [self showIap];
        }
    }
    else if ([selectedCarPanel isEqualToString:CAR_PANEL_4])
    {
        if([SystemConfig getBoolValue:CONFIG_IAP_IS_CAR_PANEL_4] == TRUE)
        {
            [self performSegueWithIdentifier:@"carPanel4Segue" sender:self];
        }
        else
        {
            [self showIap];
        }
    }
    
    [self.collectionView setContentOffset:CGPointZero animated:YES];
    [self.collectionView reloadData];
}

-(void)showIap
{
    [(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] pushViewController:buyCollectionViewController animated:TRUE];

}

@end
