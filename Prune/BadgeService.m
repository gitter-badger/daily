//
//  BadgeService.m
//  Daily
//
//  Created by Viktor Fröberg on 21/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "BadgeService.h"
#import "TodoEvent.h"

@implementation BadgeService

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Application Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self updateApplicationBadge:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self updateApplicationBadge:application];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self updateApplicationBadge:application];
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - Private

- (void)updateApplicationBadge:(UIApplication *)application
{
    NSDate *startDate = [[NSDate date] dateAtStartOfDay];
    NSDate *endDate = [[NSDate date] dateAtEndOfDay];
    NSArray *todoEvents = [TodoEvent findAllIncompleteWithStartDate:startDate endDate:endDate];
    application.applicationIconBadgeNumber = todoEvents.count;
}

@end
