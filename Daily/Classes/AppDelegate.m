//
//  AppDelegate.m
//  Prune
//
//  Created by Viktor Fröberg on 15/08/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

// Classes
#import "AppDelegate.h"

// Services
#import "MigrationService.h"
#import "UserDefaultsService.h"
#import "MagicalRecordService.h"
#import "CrashlyticsService.h"

// Controllers
#import "ApplicationViewController.h"

// Categories
#import "NSUserDefaults+DLY.h"

@interface AppDelegate ()

@property (nonatomic, strong) MagicalRecordService *magicalRecordService;
@property (nonatomic, strong) MigrationService *migrationService;
@property (nonatomic, strong) UserDefaultsService *userDefaultsService;
@property (nonatomic, strong) CrashlyticsService *crashlyticsService;

@end

@implementation AppDelegate

#pragma mark - Services

- (MagicalRecordService *)magicalRecordService
{
    if (!_magicalRecordService) {
        _magicalRecordService = [[MagicalRecordService alloc] init];
    }
    return _magicalRecordService;
}

- (MigrationService *)migrationService
{
    if (!_migrationService) {
        _migrationService = [[MigrationService alloc] init];
    }
    return _migrationService;
}

- (UserDefaultsService *)userDefaultsService
{
    if (!_userDefaultsService) {
        _userDefaultsService = [[UserDefaultsService alloc] init];
    }
    return _userDefaultsService;
}

- (CrashlyticsService *)crashlyticsService
{
    if (!_crashlyticsService) {
        _crashlyticsService = [[CrashlyticsService alloc] init];
    }
    return _crashlyticsService;
}

#pragma mark - Life Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [self.crashlyticsService startLogging];
    [self.magicalRecordService setup];
    
    // TODO: ENABLE
//    [self.migrationService run];
//    [self.notificationService listenForChanges];
//    [self.notificationService scheduleNotifications];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor redColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];

    ApplicationViewController *vc = [[ApplicationViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nc;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.userDefaultsService save];
    [self setLastSeen];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.userDefaultsService save];
    [self setLastSeen];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.userDefaultsService save];
    [self setLastSeen];
    [self.magicalRecordService clean];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNoData);
}

#pragma mark - Private

// TODO: extract...

- (void)setLastSeen
{
    [[NSUserDefaults standardUserDefaults] setLastSeen:[NSDate date]];
}

#pragma mark - Broadcasting

// TODO: extract...

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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"statusBarTappedNotification" object:nil];
}

@end
