#import <EventKit/EventKit.h>

#import "NotificationService.h"

#import "EKEventStore+VFDaily.h"

#import "TodoEvent.h"

@implementation NotificationService

- (void)setup
{
    [[UIApplication sharedApplication] registerUserNotificationSettings:self.userNotificationSettings];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChangedNotification:) name:EKEventStoreChangedNotification object:[EKEventStore sharedEventStore]];
}

- (void)scheduleNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self scheduleTodoEventNotifications];
}

- (void)presentNotification:(UILocalNotification *)notification
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        UIAlertController *alertNotificationController = [UIAlertController alertControllerWithTitle:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] message:notification.alertBody preferredStyle:UIAlertControllerStyleAlert];
        [alertNotificationController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        [rootViewController presentViewController:alertNotificationController animated:YES completion:nil];
    }
}

//- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
//{
//    if ([identifier isEqualToString:@"SNOOZE_ACTION"]) {
//        [application scheduleLocalNotification:[self snoozedNotification:notification]];
//    }
//    completionHandler();
//}

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

- (void)scheduleTodoEventNotifications
{
    if (![EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent]) { return; }

    NSDate *startDate = [NSDate date];
    NSDate *endDate = [[NSDate date] dateByAddingDays:7];
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
    UIUserNotificationType userNotificationTypes = UIUserNotificationTypeAlert | UIUserNotificationTypeSound |UIUserNotificationTypeBadge;
    
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
