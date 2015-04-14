//
//  EKCalendar+VF.m
//  Daily
//
//  Created by Viktor Fröberg on 03/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <objc/runtime.h>

#import "EKCalendar+VFDaily.h"
#import "Calendar+VFDaily.h"

@implementation EKCalendar (VFDaily)

@dynamic calendar;

- (void)setCalendar:(Calendar *)calendar
{
    objc_setAssociatedObject(self, @selector(calendar), calendar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Calendar *)calendar
{
    Calendar *calendar = objc_getAssociatedObject(self, @selector(calendar));
    if (!calendar) {
        calendar = [Calendar findOrCreateByAttribute:@"calendarIdentifier" withValue:self.calendarIdentifier];
        self.calendar = calendar;
    }
    return calendar;
}

- (NSNumber *)isEnabled
{
    if (self.enabledDate) {
        return @YES;
    }
    return @NO;
}

- (NSDate *)enabledDate
{
    return self.calendar.enabledDate;
}

- (void)setEnabledDate:(NSDate *)date
{
    self.calendar.enabledDate = date;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CalendarUpdated" object:self];
}

+ (NSArray *)calendarForEntityType:(EKEntityType)entityType
{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    return [eventStore calendarsForEntityType:entityType];
}

+ (NSArray *)selectedCalendarForEntityType:(EKEntityType)entityType
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isEnabled = %@", @YES];
    NSArray *calendars = [self calendarForEntityType:entityType];
    return [calendars filteredArrayUsingPredicate:predicate];
}

#pragma mark - Private

@end
