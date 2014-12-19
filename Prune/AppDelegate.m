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
#import "BadgeService.h"
#import "NotificationService.h"
#import "MigrationService.h"
#import "UserDefaultsService.h"
#import "MagicalRecordService.h"
#import "CrashlyticsService.h"

// Categories
#import "NSUserDefaults+DLY.h"
#import "EKEventStore+VFDaily.h"

@interface AppDelegate ()

@property (nonatomic, strong) BadgeService *badgeService;
@property (nonatomic, strong) MagicalRecordService *magicalRecordService;
@property (nonatomic, strong) MigrationService *migrationService;
@property (nonatomic, strong) NotificationService *notificationService;
@property (nonatomic, strong) UserDefaultsService *userDefaultsService;
@property (nonatomic, strong) CrashlyticsService *crashlyticsService;

@end

@implementation AppDelegate

#pragma mark - Services

- (BadgeService *)badgeService
{
    if (!_badgeService) {
        _badgeService = [[BadgeService alloc] init];
    }
    return _badgeService;
}

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

- (NotificationService *)notificationService
{
    if (!_notificationService) {
        _notificationService = [[NotificationService alloc] init];
    }
    return _notificationService;
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
    
    // TODO: Could be init instead?
    [self.crashlyticsService startLogging];
    [self.magicalRecordService setup];
    [self.migrationService run];
    [self.notificationService setup];
    [self.notificationService scheduleNotifications];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor redColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    
    BOOL userHasOnboarded = [[NSUserDefaults standardUserDefaults] userHasOboarded];
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

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self.notificationService presentNotification:notification];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSString *email = [[NSUserDefaults standardUserDefaults] email];
    if (email) {
        [[Analytics sharedAnalytics] identify:email];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.userDefaultsService save];
    [self setLastSeen];
    [[EKEventStore sharedEventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            [self.badgeService updateBadge:application];
            [self.magicalRecordService clean];
        }
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.userDefaultsService save];
    [self setLastSeen];
    [[EKEventStore sharedEventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            [self.badgeService updateBadge:application];
            [self.magicalRecordService clean];
        }
    }];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.userDefaultsService save];
    [self setLastSeen];
    [[EKEventStore sharedEventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            [self.badgeService updateBadge:application];
            [self.magicalRecordService clean];
        }
    }];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self.crashlyticsService startLogging];
    [self.magicalRecordService setup];
    [[EKEventStore sharedEventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            [self.badgeService updateBadge:application];
            [self.notificationService scheduleNotifications];
            [self.magicalRecordService clean];
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }];
}

#pragma mark - Private

// Todo extract...

- (void)setLastSeen
{
    [[NSUserDefaults standardUserDefaults] setLastSeen:[NSDate date]];
}

#pragma mark - Broadcasting

// Todo extract...

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
