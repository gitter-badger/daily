#import <Foundation/Foundation.h>

@interface NotificationService : NSObject

- (void)listenForChanges;
- (void)scheduleNotifications;
- (void)presentNotification:(UILocalNotification *)notification;

@end
