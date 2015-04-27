//
//  Todo+Extended.m
//  Daily
//
//  Created by Viktor Fröberg on 27/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "Todo+Extended.h"
#import "EKCalendar+VFDaily.h"

@implementation Todo (Extended)

+ (instancetype)findOrCreateWithEvent:(EKEvent *)event date:(NSDate *)date inContext:(NSManagedObjectContext *)context
{
    NSString *todoIdentifier = [Todo todoIdentifierFromEventIdentifier:event.eventIdentifier date:date];
    Todo *todo = [self findFirstByAttribute:@"todoIdentifier" withValue:todoIdentifier inContext:context];
    if (!todo) {
        NSDate *eventModifiedDate = [event.lastModifiedDate startOfDay];
        NSDate *calendarEnabledDate = [event.calendar.enabledDate startOfDay];
        NSDate *dayBeforeCalendarEnabledDate = [calendarEnabledDate dateBySubtractingDays:1];
        
        BOOL eventOccursAfterCalendarWasEnabled = [date isAfterDate:dayBeforeCalendarEnabledDate];
        BOOL eventWasModifiedAfterCalendarWasEnabled = [eventModifiedDate isAfterDate:dayBeforeCalendarEnabledDate];
        
        NSNumber *completed;
        if (eventOccursAfterCalendarWasEnabled || eventWasModifiedAfterCalendarWasEnabled) {
            completed = @NO;
        } else {
            completed = @YES;
        }
        
        todo = [self createTodoWithTodoIdentifier:todoIdentifier date:date completed:completed inContext:context];
    }
    return todo;
}

+ (instancetype)createTodoWithTodoIdentifier:(NSString *)todoIdentifier date:(NSDate *)date completed:(NSNumber *)completed inContext:(NSManagedObjectContext *)context
{
    Todo *todo = [Todo createInContext:context];
    todo.todoIdentifier = todoIdentifier;
    todo.date = [date startOfDay];
    todo.position = @-1;
    todo.completed = completed;
    return todo;
}

+ (NSString *)todoIdentifierFromEventIdentifier:(NSString *)eventIdentifier date:(NSDate *)date;
{
    static NSDateFormatter *dayMonthYearFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dayMonthYearFormatter = [[NSDateFormatter alloc] init];
        dayMonthYearFormatter.dateFormat = @"ddMMyyyy";
    });
    
    NSString *dateString = [dayMonthYearFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@-%@", eventIdentifier, dateString];
}

@end
