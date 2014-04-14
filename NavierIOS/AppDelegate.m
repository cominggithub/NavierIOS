//
//  AppDelegate.m
//  NavierIOS
//
//  Created by Coming on 13/2/25.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import <NaviUtil/NaviUtil.h>
#import "GoogleAPIKey.h"

#import "RSSecrets.h"


#define FILE_DEBUG FALSE
#include <NaviUtil/Log.h>


@implementation AppDelegate
{
    AVAudioPlayer *audioPlayer;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [GMSServices provideAPIKey:GOOGLE_API_Key];
    [NaviUtil setGoogleAPIKey:GOOGLE_API_Key];
    [NaviUtil setGooglePlaceAPIKey:GOOGLE_PLACE_API_Key];
    [NaviUtil init];
    [SysConfig setFloatValue:CONFIG_DEFAULT_BRIGHTNESS float:[UIScreen mainScreen].brightness];
    [User save];

    [Appirater setAppId:@"806144673"];    // Change for your "Your APP ID"
    [Appirater setDaysUntilPrompt:0];     // Days from first entered the app until prompt
#if RELEASE
    [Appirater setUsesUntilPrompt:10];     // Number of uses until prompt
#else
    [Appirater setUsesUntilPrompt:3];     // Number of uses until prompt
#endif
    [Appirater setTimeBeforeReminding:2];
    
#if DEBUG
    [Appirater setDebug:YES];
#else
    [Appirater setDebug:NO];
#endif
    
    [SysConfig setValue:CONFIG_USE_COUNT int:[SysConfig getIntValue:CONFIG_USE_COUNT]+1];
    
    // 23.002518, 120.203524
    
/*
    Place *p1 = [[Place alloc] initWithName:@"甜蜜的家" address:@"冬山" coordinate:CLLocationCoordinate2DMake(23.011051, 120.194082)];
    p1.placeType = kPlaceType_Home;
    
    Place *p2 = [[Place alloc] initWithName:@"血汗辦公室" address:@"南科" coordinate:CLLocationCoordinate2DMake(23.013895, 120.232277)];
    p2.placeType = kPlaceType_Office;

    Place *p3 = [[Place alloc] initWithName:@"台南牛肉湯" address:@"冬山" coordinate:CLLocationCoordinate2DMake(23.002992, 120.186701)];
    p3.placeType = kPlaceType_Favor;

    Place *p4 = [[Place alloc] initWithName:@"雞湯塊鼎王" address:@"冬山" coordinate:CLLocationCoordinate2DMake(22.989719, 120.201979)];
    p4.placeType = kPlaceType_Favor;

    Place *p5 = [[Place alloc] initWithName:@"搜尋-天然食品" address:@"冬山" coordinate:CLLocationCoordinate2DMake(22.990509, 120.225496)];
    p5.placeType = kPlaceType_SearchedPlace;
    

    [User clearConfig];
    [User addHomePlace:p1];
    [User addOfficePlace:p2];
    [User addFavorPlace:p3];
    [User addFavorPlace:p4];

    [User addRecentPlace:p5];
    [User addRecentPlace:p4];
    [User addRecentPlace:p3];
    [User addRecentPlace:p2];
    [User addRecentPlace:p1];
*/
#if DEBUG
//    [RSSecrets addKey:@"IAP_AdvancedVersion"];
//    NSLog(@"%@: %@", @"IAP_AdvancedVersion", [RSSecrets hasKey:@"IAP_AdvancedVersion"]?@"TRUE":@"FALSE");
#endif
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /* restore to default brightnes */
    [[UIScreen mainScreen] setBrightness:[SysConfig getFloatValue:CONFIG_DEFAULT_BRIGHTNESS]];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /* restore to default brightnes */
    [[UIScreen mainScreen] setBrightness:[SysConfig getFloatValue:CONFIG_DEFAULT_BRIGHTNESS]];

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
    [SysConfig setValue:CONFIG_USE_COUNT int:[SysConfig getIntValue:CONFIG_USE_COUNT]+1];
    
    /* get the default brightness */
    [SysConfig setFloatValue:CONFIG_DEFAULT_BRIGHTNESS float:[UIScreen mainScreen].brightness];
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationWillEnterForeground" object:self];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /* get the default brightness */
    
    [SysConfig setFloatValue:CONFIG_DEFAULT_BRIGHTNESS float:[UIScreen mainScreen].brightness];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidBecomeActive" object:self];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    /* restore to default brightnes */
    [[UIScreen mainScreen] setBrightness:[SysConfig getFloatValue:CONFIG_DEFAULT_BRIGHTNESS]];
#if RELEASE_TEST
    [SystemConfig removeIAPItem:CONFIG_IAP_IS_ADVANCED_VERSION];
#endif

}

@end
