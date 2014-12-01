//
//  TodoStoreService.m
//  Daily
//
//  Created by Viktor Fröberg on 20/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "TodoEventStoreService.h"
#import "TodoEventStore.h"

@implementation TodoEventStoreService

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Application Delegate

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[TodoEventStore sharedTodoEventStore] save];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[TodoEventStore sharedTodoEventStore] save];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[TodoEventStore sharedTodoEventStore] save];
}

# pragma mark - Private

@end
