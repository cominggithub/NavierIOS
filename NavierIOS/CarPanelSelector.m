//
//  CarPanelSelector.m
//  NavierIOS
//
//  Created by Coming on 10/19/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CarPanelSelector.h"
#import <NaviUtil/NaviUtil.h>


#if DEBUG
#define FILE_DEBUG TRUE
#elif RELEASE_TEST
#define FILE_DEBUG FALSE
#else
#define FILE_DEBUG FALSE
#endif

#include "Log.h"

@implementation CarPanelSelector
{
    NSMutableDictionary* carPanelUsageLog;
    NSInteger segNumber;
}

-(id)init
{
    self = [super init];
    
    if (self)
    {
        [self initSelf];
    }
    
    return self;
}


-(void)initSelf
{
    segNumber = 0;
    carPanelUsageLog = [[NSUserDefaults standardUserDefaults] objectForKey:CAR_PANEL_USAGE_LOG];
    if (carPanelUsageLog == nil)
    {
        [self resetLog];
    }
    
    for (NSString* carPanel in carPanelUsageLog.allKeys)
    {
        CarPanelUsage *cpu = [self carPanelUsageByCarPanel:carPanel];
        if (cpu.usedSequenceNumber > segNumber)
        {
            segNumber = cpu.usedSequenceNumber;
        }
    }
    segNumber++;
    [self refershImages];
    [self dump];
}

-(void)resetLog
{
    segNumber = 0;
    
    carPanelUsageLog = [[NSMutableDictionary alloc] initWithCapacity:4];
    [self addCarPanelUsage:CAR_PANEL_4];
    [self addCarPanelUsage:CAR_PANEL_3];
    [self addCarPanelUsage:CAR_PANEL_2];
    [self addCarPanelUsage:CAR_PANEL_1];
    
    [self saveLog];

}

-(void)useCarPanel:(NSString*)carPanel
{
    CarPanelUsage *cpu;
    cpu = [self carPanelUsageByCarPanel:carPanel];

    if (nil == cpu)
        return;
    
    cpu.count++;
    cpu.usedSequenceNumber = segNumber++;
    [self saveCarPanelUsage:cpu];
    [self refershImages];
    [self saveLog];
    
}

-(void)refershImages
{
    NSMutableArray *images;
    NSArray *carPanelList;
    images = [[NSMutableArray alloc] initWithCapacity:4];
    carPanelList = [self lruCarPanelUsage];
    
    if ([SystemManager lanscapeScreenRect].size.width >= 568)
    {
        for (CarPanelUsage *cpu in carPanelList)
        {
            [images addObject:cpu.name];
        }
    }
    else
    {
        for (CarPanelUsage *cpu in carPanelList)
        {
            if (![cpu.name isEqualToString:CAR_PANEL_4])
            {
                [images addObject:cpu.name];
            }
        }
    }
    
    self.iapImages = [NSArray arrayWithArray:images];
}

-(void)addCarPanelUsage:(NSString*)carPanel
{
    CarPanelUsage* cpu;
    cpu                     = [[CarPanelUsage alloc] init];
    cpu.name                = carPanel;
    cpu.count               = 0;
    cpu.usedSequenceNumber  = segNumber++;

    [self saveCarPanelUsage:cpu];
}

-(void)saveCarPanelUsage:(CarPanelUsage*)cpu
{
    NSData *encodedObj;
    encodedObj = [NSKeyedArchiver archivedDataWithRootObject:cpu];
    [carPanelUsageLog setValue:encodedObj forKey:cpu.name];
}

-(CarPanelUsage*)carPanelUsageByCarPanel:(NSString*)carPanel
{
    NSData *encodedObj;
    CarPanelUsage* cpu;
    
    encodedObj = [carPanelUsageLog valueForKey:carPanel];
    cpu = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObj];
    return cpu;
}

-(void)saveLog
{
    [[NSUserDefaults standardUserDefaults] setObject:carPanelUsageLog forKey:CAR_PANEL_USAGE_LOG];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSArray*)lruCarPanelUsage
{
    NSMutableArray* carPanelUsageList;
    NSInteger i;
    CarPanelUsage* tmpCpu;
    
    carPanelUsageList = [[NSMutableArray alloc] initWithCapacity:4];

    for (NSString* carPanel in carPanelUsageLog.allKeys)
    {
        CarPanelUsage *cpu = [self carPanelUsageByCarPanel:carPanel];
        for(i=0; i<carPanelUsageList.count; i++)
        {
            tmpCpu = [carPanelUsageList objectAtIndex:i];
            if (cpu.usedSequenceNumber > tmpCpu.usedSequenceNumber)
            {
                break;
            }
        }
        
        [carPanelUsageList insertObject:cpu atIndex:i];
    }
    
    return carPanelUsageList;
}

-(void)dump
{
    for (NSString* carPanel in carPanelUsageLog.allKeys)
    {
        CarPanelUsage *cpu = [self carPanelUsageByCarPanel:carPanel];
        logO(cpu);
    }
}
@end
