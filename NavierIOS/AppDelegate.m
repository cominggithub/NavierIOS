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
#import <FacebookSDK/FacebookSDK.h>
#import "GoogleAPIKey.h"
#import "GoogleUtil.h"


#import "RSSecrets.h"
#import "BuyUIViewController.h"
#import "BuyCollectionViewController.h"



#define FILE_DEBUG FALSE
#include <NaviUtil/Log.h>


@implementation AppDelegate
{
    AVAudioPlayer       *audioPlayer;
    BuyUIViewController *buyViewController;
    BuyCollectionViewController *buyCollectionViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [self initSelf];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /* restore to default brightnes */
    [[UIScreen mainScreen] setBrightness:[SystemConfig getFloatValue:CONFIG_DEFAULT_BRIGHTNESS]];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /* restore to default brightnes */
    [[UIScreen mainScreen] setBrightness:[SystemConfig getFloatValue:CONFIG_DEFAULT_BRIGHTNESS]];
    [self inactive];

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];

    [SystemConfig setValue:CONFIG_USE_COUNT int:[SystemConfig getIntValue:CONFIG_USE_COUNT]+1];
    
    /* get the default brightness */
    [SystemConfig setFloatValue:CONFIG_DEFAULT_BRIGHTNESS float:[UIScreen mainScreen].brightness];
 
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isBuyShown"];
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationWillEnterForeground" object:self];

    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /* get the default brightness */
    [SystemConfig setFloatValue:CONFIG_DEFAULT_BRIGHTNESS float:[UIScreen mainScreen].brightness];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidBecomeActive" object:self];
    [self active];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    /* restore to default brightnes */
    [[UIScreen mainScreen] setBrightness:[SystemConfig getFloatValue:CONFIG_DEFAULT_BRIGHTNESS]];
#if DEBUG
    [RSSecrets removeKey:@"IAP_AdvancedVersion"];
    NSLog(@"%@: %@", @"IAP_AdvancedVersion", [RSSecrets hasKey:@"IAP_AdvancedVersion"]?@"TRUE":@"FALSE");
#elif RELEASE_TEST
    [RSSecrets removeKey:@"IAP_AdvancedVersion"];
#elif RELEASE
#endif

}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      NSLog(@"Unhandled deep link: %@", url);
                                      // Here goes the code to handle the links
                                      // Use the links to show a relevant view of your app to the user
                                  }];
    
    return urlWasHandled;
}

#pragma mark -- init
-(void) initSelf
{
    // Override point for customization after application launch.
    NSError *error;
    
    
    [self initGoogleSetting];
    [self initNaviUtil];
    [self initAppirater];
    
    [SystemConfig setFloatValue:CONFIG_DEFAULT_BRIGHTNESS float:[UIScreen mainScreen].brightness];
    
    // mix voice guidance with playing music
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];
    
    UIStoryboard *storyboard          = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    buyViewController           = (BuyUIViewController *)[storyboard instantiateViewControllerWithIdentifier:NSStringFromClass ([BuyUIViewController class])];
    buyCollectionViewController = (BuyCollectionViewController *)[storyboard instantiateViewControllerWithIdentifier:NSStringFromClass ([BuyCollectionViewController class])];
    
#if DEBUG
    [RSSecrets removeKey:@"IAP_AdvancedVersion"];
//    [self initDebugPlace];
//        [RSSecrets addKey:@"IAP_AdvancedVersion"];
    //    NSLog(@"%@: %@", @"IAP_AdvancedVersion", [RSSecrets hasKey:@"IAP_AdvancedVersion"]?@"TRUE":@"FALSE");
#elif RELEASE_TEST
    [RSSecrets addKey:@"IAP_AdvancedVersion"];
#elif RELEASE
#endif
    
}
-(void)initAppirater
{
    [Appirater setAppId:@"806144673"];    // Change for your "Your APP ID"
    [Appirater setDaysUntilPrompt:0];     // Days from first entered the app until prompt
#if RELEASE
    [Appirater setUsesUntilPrompt:3];     // Number of uses until prompt
#else
    [Appirater setUsesUntilPrompt:100];     // Number of uses until prompt
#endif
    [Appirater setTimeBeforeReminding:2];
    
#if DEBUG
    [Appirater setDebug:NO];
#else
    [Appirater setDebug:NO];
#endif
    [Appirater appEnteredForeground:YES];
    
    if (0 == [Appirater useCount])
    {
        [RSSecrets removeKey:@"IAP_AdvancedVersion"];
    }
    
    [SystemConfig setValue:CONFIG_USE_COUNT int:[SystemConfig getIntValue:CONFIG_USE_COUNT]+1];

}

-(void)initDebugPlace
{
    Place *p;
    
    [User clearConfig];
    
    p = [[Place alloc] initWithName:@"永康家" address:@"" coordinate:CLLocationCoordinate2DMake(23.030062,120.253609)];
    p.placeType = kPlaceType_Home;
    [User addHomePlace:p];
    [User addRecentPlace:p];

    p = [[Place alloc] initWithName:@"奇美" address:@"" coordinate:CLLocationCoordinate2DMake(23.020549, 120.221723)];
    p.placeType = kPlaceType_Home;
    [User addFavorPlace:p];
    [User addRecentPlace:p];
    

    p = [[Place alloc] initWithName:@"成大" address:@"" coordinate:CLLocationCoordinate2DMake(22.996604, 120.215739)];
    p.placeType = kPlaceType_Home;
    [User addFavorPlace:p];
    [User addRecentPlace:p];
    
    p = [[Place alloc] initWithName:@"緩緩" address:@"" coordinate:CLLocationCoordinate2DMake(23.003439, 120.219086)];
    p.placeType = kPlaceType_Home;
    [User addFavorPlace:p];
    [User addRecentPlace:p];

    p = [[Place alloc] initWithName:@"裕文圖書館" address:@"" coordinate:CLLocationCoordinate2DMake(22.982044, 120.245077)];
    p.placeType = kPlaceType_Home;
    [User addFavorPlace:p];
    [User addRecentPlace:p];

    p = [[Place alloc] initWithName:@"南台" address:@"" coordinate:CLLocationCoordinate2DMake(23.025519,120.226640)];
    p.placeType = kPlaceType_Home;
    [User addFavorPlace:p];
    [User addRecentPlace:p];
    
    
    
    
    [User save];
}

-(void)initGoogleSetting
{
    [GMSServices provideAPIKey:GOOGLE_API_Key];
    [GoogleUtil initializeGoogleAnalytics];
    [GoogleUtil setVerbose:FALSE];
}

-(void)initNaviUtil
{
    [NaviUtil setGoogleAPIKey:GOOGLE_API_Key];
    [NaviUtil setGooglePlaceAPIKey:GOOGLE_PLACE_API_Key];
    [NaviUtil init];
}

-(void)showIap
{
    
    if ([SystemConfig getIntValue:CONFIG_USE_COUNT] > 5 && [SystemConfig getIntValue:CONFIG_USE_COUNT] %4 == 0 &&
        [SystemConfig getBoolValue:CONFIG_H_IS_AD])
    {
    
        if (YES == [NavierHUDIAPHelper hasUnbroughtIap] &&
            IAP_STATUS_RETRIEVED == [NavierHUDIAPHelper retrieveIap] &&
            NO == buyCollectionViewController.buying)
        {
            //[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] pushViewController:buyViewController animated:TRUE];
            [(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] pushViewController:buyCollectionViewController animated:TRUE];
        }
    }
}

- (void)active
{
    [LocationManager start];

#if DEBUG
    [self showIap];
#elif RELEASE_TEST
    
#else
    [self showIap];
#endif
}

- (void)inactive
{
    [LocationManager stop];
}

@end
