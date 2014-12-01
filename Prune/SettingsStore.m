//
//  SettingsStore.m
//  Daily
//
//  Created by Viktor Fröberg on 21/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <EventKit/EventKit.h>

#import "SettingsStore.h"

#import "TodoEventStore.h"

@implementation SettingsStore

+ (instancetype)sharedSettingsStore {
    static id _sharedSettingsStore = nil;
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedSettingsStore = [[SettingsStore alloc] init];
    });
    return _sharedSettingsStore;
}

- (NSArray *)calendarIdentifiers
{
    NSArray *calendarIdentifiers = [[NSUserDefaults standardUserDefaults] objectForKey:@"calendarIdentifiers"];
    return calendarIdentifiers;
}

- (void)setCalendarIdentifiers:(NSArray *)calendarIdentifiers
{
    [[NSUserDefaults standardUserDefaults] setObject:calendarIdentifiers forKey:@"calendarIdentifiers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)calendars
{
    NSArray *calendars = [[TodoEventStore sharedTodoEventStore].eventStore calendarsForEntityType:EKEntityTypeEvent];
    if (!self.calendarIdentifiers) {
        return calendars;
    }
    NSPredicate *selectedCalendarsPredicate = [NSPredicate predicateWithBlock:^BOOL(EKCalendar *calendar, NSDictionary *bindings) {
        if ([self.calendarIdentifiers containsObject:calendar.calendarIdentifier]) {
            return YES;
        } else {
            return NO;
        }
    }];
    return [calendars filteredArrayUsingPredicate:selectedCalendarsPredicate];
}

- (void)setCalendars:(NSArray *)selectedCalendars
{
    self.calendarIdentifiers = [selectedCalendars valueForKey:@"calendarIdentifier"];
}

@end
