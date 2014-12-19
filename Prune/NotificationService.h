#import <Foundation/Foundation.h>

@interface NotificationService : NSObject

- (void)setup;
- (void)scheduleNotifications;
- (void)presentNotification:(UILocalNotification *)notification;

@end
