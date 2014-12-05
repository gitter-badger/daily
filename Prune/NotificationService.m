//
//  PushNotificationService.m
//  ServiceOrientedAppDelegate
//
//  Created by Nico Hämäläinen on 09/02/14.
//  Copyright (c) 2014 Nico Hämäläinen. All rights reserved.
//

#import <EventKit/EventKit.h>

#import "NotificationService.h"

#import "TodoEvent.h"

#import "EKEventStore+VFDaily.h"

@implementation NotificationService

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Application Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChangedNotification:) name:EKEventStoreChangedNotification object:[EKEventStore sharedEventStore]];
    
    [application registerUserNotificationSettings:self.userNotificationSettings];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self scheduleNotifications];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self scheduleNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self scheduleNotifications];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Daily" message:notification.alertBody preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [application.delegate.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"SNOOZE_ACTION"]) {
        [application scheduleLocalNotification:[self snoozedNotification:notification]];
    }
    completionHandler();
}

# pragma mark - Private

- (void)eventStoreChangedNotification:(NSNotification *)notification {
    [self scheduleTodoEventNotifications];
}

- (UILocalNotification *)snoozedNotification:(UILocalNotification *)notification
{
    NSInteger minute = 60;
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5 * minute];
    return notification;
}

- (void)scheduleNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [self scheduleTodoEventNotifications];
}

- (void)scheduleTodoEventNotifications
{
    if (![EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent]) { return; }

    NSDate *startDate = [NSDate date];
    NSDate *endDate = [NSDate dateWithDaysFromNow:14];
    NSArray *todoEvents = [TodoEvent findAllIncompleteWithStartDate:startDate endDate:endDate];
    TodoEvent *todoEvent;

    for (todoEvent in todoEvents) {
        [self scheduleNotificationForTodoEvent:todoEvent];
    }
}

- (void)scheduleNotificationForTodoEvent:(TodoEvent *)todoEvent
{
    NSArray *notifications = [todoEvent localNotifications];
    UILocalNotification *notification;
    
    for (notification in notifications) {
        if ([notification.fireDate isInFuture]) {
//            notification.category = @"SNOOZE_CATEGORY";
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
}

- (UIUserNotificationSettings *)userNotificationSettings
{
    NSSet *userNotificationCategories = [NSSet setWithArray:@[self.snoozableUserNotificationCategory]];
    UIUserNotificationType userNotificationTypes = UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge;
    
    UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:userNotificationCategories];
    
    return userNotificationSettings;
}

- (UIMutableUserNotificationCategory *)snoozableUserNotificationCategory
{
    UIMutableUserNotificationCategory *snoozable = [[UIMutableUserNotificationCategory alloc] init];
    snoozable.identifier = @"SNOOZE_CATEGORY";
    [snoozable setActions:@[self.snoozeUserNotificationAction] forContext:UIUserNotificationActionContextDefault];
    [snoozable setActions:@[self.snoozeUserNotificationAction] forContext:UIUserNotificationActionContextMinimal];
    
    return snoozable;
}

- (UIUserNotificationAction *)snoozeUserNotificationAction
{
    UIMutableUserNotificationAction *snoozeAction = [[UIMutableUserNotificationAction alloc] init];
    snoozeAction.identifier = @"SNOOZE_ACTION";
    snoozeAction.title = @"Snooze";
    snoozeAction.destructive = NO;
    snoozeAction.authenticationRequired = NO;
    snoozeAction.activationMode = UIUserNotificationActivationModeBackground;
    
    return snoozeAction;
}

@end
