//
//  AppDelegate.m
//  Prune
//
//  Created by Viktor Fröberg on 15/08/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <EventKit/EventKit.h>

#import "DAYAnalytics.h"
#import "AppDelegate.h"

#import "BadgeService.h"
#import "NotificationService.h"
#import "TodoEventStoreService.h"

#import "MasterViewController.h"

#import "NSDate+Utilities.h"

static NSString * const kUserHasOnboarded = @"userHasOnboarded";
static NSString * const kUserOnboardedAt = @"userOnboardedAt";
static NSString * const kUserEmail = @"userEmail";
static NSString * const kStatusBarTappedNotification = @"statusBarTappedNotification";
static NSString * const kLastClosedDate = @"lastClosedDate";

@interface AppDelegate ()

@property (nonatomic, strong) NSArray *calendarIdentifiers;
@property (nonatomic, strong) NSArray *selectedCalendars;

@end

@implementation AppDelegate

#pragma mark - Services

- (NSArray *)services {
    static NSArray * _services;
    static dispatch_once_t _onceTokenServices;
    dispatch_once(&_onceTokenServices, ^{
        _services = @[[BadgeService sharedInstance], [NotificationService sharedInstance], [TodoEventStoreService sharedInstance]];
    });
    return _services;
}

#pragma mark - Life Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor redColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    
    BOOL userHasOnboarded = [[NSUserDefaults standardUserDefaults] boolForKey:kUserHasOnboarded];
    if (userHasOnboarded) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
        self.window.rootViewController = [storyboard instantiateInitialViewController];
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboard_iPhone" bundle:[NSBundle mainBundle]];
        self.window.rootViewController = [storyboard instantiateInitialViewController];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    BOOL userHasOnboarded = [[NSUserDefaults standardUserDefaults] boolForKey:kUserHasOnboarded];
    NSString *email = [[NSUserDefaults standardUserDefaults] valueForKey:kUserEmail];
    if (userHasOnboarded) {
        [[DAYAnalytics sharedAnalytics] identify:email traits:nil];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [super applicationWillResignActive:application];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastClosedDate];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [super applicationDidEnterBackground:application];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastClosedDate];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [super applicationWillTerminate:application];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastClosedDate];
}

#pragma mark - Broadcasting

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    
    if (CGRectContainsPoint(statusBarFrame, location)) {
        [self statusBarTappedAction];
    }
}

- (void)statusBarTappedAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStatusBarTappedNotification object:nil];
}

@end
