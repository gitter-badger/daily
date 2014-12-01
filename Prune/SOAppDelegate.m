//
//  SOAppDelegate.m
//  ServiceOrientedAppDelegate
//
//  Created by Nico Hämäläinen on 09/02/14.
//  Copyright (c) 2014 Nico Hämäläinen. All rights reserved.
//

#import "SOAppDelegate.h"

@implementation SOAppDelegate

- (NSArray *)services {
    return nil;
}

#pragma mark - UIApplication Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    id<UIApplicationDelegate> service;
    for(service in self.services){
        if ([service respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)]){
            [service application:application didFinishLaunchingWithOptions:launchOptions];
        }
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    id<UIApplicationDelegate> service;
    for(service in self.services){
        if ([service respondsToSelector:@selector(applicationWillResignActive:)]){
            [service applicationWillResignActive:application];
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    id<UIApplicationDelegate> service;
    for(service in self.services){
        if ([service respondsToSelector:@selector(applicationDidEnterBackground:)]){
            [service applicationDidEnterBackground:application];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    id<UIApplicationDelegate> service;
    for(service in self.services){
        if ([service respondsToSelector:@selector(applicationWillEnterForeground:)]){
            [service applicationWillEnterForeground:application];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    id<UIApplicationDelegate> service;
    for(service in self.services){
        if ([service respondsToSelector:@selector(applicationDidBecomeActive:)]){
            [service applicationDidBecomeActive:application];
        }
    }

}

- (void)applicationWillTerminate:(UIApplication *)application {
    id<UIApplicationDelegate> service;
    for(service in self.services){
        if ([service respondsToSelector:@selector(applicationWillTerminate:)]){
            [service applicationWillTerminate:application];
        }
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    id<UIApplicationDelegate> service;
    BOOL result = NO;
    for(service in self.services){
        if ([service respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]){
            result |= [service application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
        }
    }
    return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    id<UIApplicationDelegate> service;
    BOOL result = NO;
    for(service in self.services){
        if ([service respondsToSelector:@selector(application:handleOpenURL:)]){
            result |= [service application:application handleOpenURL:url];
        }
    }
    return result;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    id<UIApplicationDelegate> service;
    for(service in self.services){
        if ([service respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]){
            [service application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
        }
    }

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    id<UIApplicationDelegate> service;
    for(service in self.services){
        if ([service respondsToSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)]){
            [service application:application didFailToRegisterForRemoteNotificationsWithError:error];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    id<UIApplicationDelegate> service;
    for(service in self.services){
        if ([service respondsToSelector:@selector(application:didReceiveLocalNotification:)]){
            [service application:application didReceiveLocalNotification:notification];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    id<UIApplicationDelegate> service;
    for(service in self.services){
        if ([service respondsToSelector:@selector(application:didReceiveRemoteNotification:)]){
            [service application:application didReceiveRemoteNotification:userInfo];
        }
    }
}

void (^allVoid)(void);

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSMutableArray *fetchResults = [NSMutableArray array];
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    id<UIApplicationDelegate> service;
    for(service in self.services){
        if ([service respondsToSelector:@selector(application:performFetchWithCompletionHandler:)]){
            dispatch_group_enter(serviceGroup);
            [service application:application performFetchWithCompletionHandler:^(UIBackgroundFetchResult result) {
                [fetchResults addObject:[NSNumber numberWithInt:result]];
                dispatch_group_leave(serviceGroup);
            }];
        }
    }
    
    dispatch_group_notify(serviceGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if ([fetchResults containsObject:[NSNumber numberWithInt:UIBackgroundFetchResultFailed]]) {
            completionHandler(UIBackgroundFetchResultFailed);
        }
        else if ([fetchResults containsObject:[NSNumber numberWithInt:UIBackgroundFetchResultNoData]]) {
            completionHandler(UIBackgroundFetchResultNoData);
        }
        else {
            completionHandler(UIBackgroundFetchResultNewData);
        }
    });
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    id<UIApplicationDelegate> service;
    for(service in self.services){
        if ([service respondsToSelector:@selector(application:handleActionWithIdentifier:forLocalNotification:completionHandler:)]){
            [service application:application handleActionWithIdentifier:identifier forLocalNotification:notification completionHandler:completionHandler];
        }
    }
}

@end
