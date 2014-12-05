//
//  MigrationService.m
//  Daily
//
//  Created by Viktor Fröberg on 04/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <MTMigration/MTMigration.h>
#import "MigrationService.h"
#import "Calendar.h"
#import "EKCalendar+VFDaily.h"
#import "Todo+VFDaily.h"

@implementation MigrationService

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
    [MTMigration migrateToVersion:@"1.0" block:^{
        [self migrateSelectedCalendarsFromUserDefaults];
        [Todo migrateFromTodoIdentifiers];
    }];
    return YES;
}

#pragma mark - Private

- (void)migrateSelectedCalendarsFromUserDefaults
{
//    TodoEventStore *todoEventStore = [TodoEventStore sharedTodoEventStore];
//    NSArray *selectedCalendarIdentifiers = [[NSUserDefaults standardUserDefaults] objectForKey:@"calendarIdentifier"];
//    NSArray *calendars = [todoEventStore calendars];
//    [calendars enumerateObjectsUsingBlock:^(EKCalendar *calendar, NSUInteger idx, BOOL *stop) {
//        if ([selectedCalendarIdentifiers containsObject:calendar.calendarIdentifier]) {
//            calendar.enabledDate = [NSDate date];
//        } else {
//            calendar.enabledDate = nil;
//        }
//    }];
}

@end
