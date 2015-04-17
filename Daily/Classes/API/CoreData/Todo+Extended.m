//
//  Todo+Extended.m
//  Daily
//
//  Created by Viktor Fröberg on 27/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "Todo+Extended.h"

@implementation Todo (Extended)

+ (instancetype)todoFromEvent:(EKEvent *)event forDate:(NSDate *)date inContext:(NSManagedObjectContext *)context
{
    NSString *todoIdentifier = [self todoIdentifierFromEventIdentifier:event.eventIdentifier date:date];

    Todo *todo = [Todo createInContext:context];
    todo.todoIdentifier = todoIdentifier;
    todo.date = date;
    todo.position = @-1;

    NSDate *eventModifiedDate = [event.lastModifiedDate startOfDay];
    NSDate *calendarEnabledDate = [[NSDate date] startOfDay]; //TODO: Refactor [event.calendar.enabledDate startOfDay];
    NSDate *dayBeforeCalendarEnabledDate = [calendarEnabledDate dateBySubtractingDays:1];

    BOOL eventOccursAfterCalendarWasEnabled = [date isAfterDate:dayBeforeCalendarEnabledDate];
    BOOL eventWasModifiedAfterCalendarWasEnabled = [eventModifiedDate isAfterDate:dayBeforeCalendarEnabledDate];

    if (eventOccursAfterCalendarWasEnabled || eventWasModifiedAfterCalendarWasEnabled) {
        todo.completed = @NO;
    } else {
        todo.completed = @YES;
    }

    return todo;
}

+ (NSString *)todoIdentifierFromEventIdentifier:(NSString *)eventIdentifier date:(NSDate *)date;
{
    static NSDateFormatter *dayMonthYearFormatter;
    if (!dayMonthYearFormatter) {
        dayMonthYearFormatter = [[NSDateFormatter alloc] init];
        dayMonthYearFormatter.dateFormat = @"ddMMyyyy";
    }
    
    NSString *dateString = [dayMonthYearFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@-%@", eventIdentifier, dateString];
}

@end
