//
//  DAYTodoEvent.m
//  Daily
//
//  Created by Viktor Fröberg on 07/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "TodoEvent.h"
#import "Todo+Extended.h"

@interface TodoEvent () <NSCopying>

@end

@implementation TodoEvent

+ (instancetype)todoEventFromTodo:(Todo *)todo event:(EKEvent *)event
{
    TodoEvent *todoEvent = [[TodoEvent alloc] init];
    if (event) {
        todoEvent.title = event.title;
        todoEvent.allDay = event.allDay;
        todoEvent.startDate = event.startDate;
        todoEvent.endDate = event.endDate;
        todoEvent.location = event.location;
        todoEvent.notes = event.notes;
        todoEvent.url = event.URL.absoluteString;
    }
    if (todo) {
        todoEvent.todoEventIdentifier = todo.todoIdentifier;
        todoEvent.completed = todo.completed.boolValue;
        todoEvent.position = todo.position.integerValue;
        todoEvent.date = todo.date;
    }
    
    return todoEvent;
}

+ (NSString *)eventIdentifierFromTodoEventIdentifier:(NSString *)todoEventIdentifier
{
    // %eventIdentifier-yyyyMMdd
    return [todoEventIdentifier substringToIndex:todoEventIdentifier.length - 9];
}

+ (NSDate *)dateFromTodoEventIdentifier:(NSString *)todoEventIdentifier
{
    static NSDateFormatter *dayMonthYearFormatter;
    if (!dayMonthYearFormatter) {
        dayMonthYearFormatter = [[NSDateFormatter alloc] init];
        dayMonthYearFormatter.dateFormat = @"ddMMyyyy";
    }
    // %eventIdentifier-yyyyMMdd
    NSString *dateString = [todoEventIdentifier substringFromIndex:todoEventIdentifier.length - 8];
    return [dayMonthYearFormatter dateFromString:dateString];
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    return [self isEqualToTodoEvent:object];
}


- (BOOL)isEqualToTodoEvent:(TodoEvent *)todoEvent
{
    return [todoEvent.todoEventIdentifier isEqual:self.todoEventIdentifier];
}

- (BOOL)hasFutureEvents
{
    // TODO: FIX THIS...
    return NO;
}

- (NSString *)description
{
    return self.title;
}

- (id)copyWithZone:(NSZone *)zone
{
    TodoEvent *todoEventCopy = [[TodoEvent allocWithZone:zone] init];
    
    todoEventCopy.todoEventIdentifier = self.todoEventIdentifier;
    todoEventCopy.title = self.title;
    todoEventCopy.location = self.location;
    todoEventCopy.notes = self.notes;
    todoEventCopy.url = self.url;
    
    todoEventCopy.startDate = self.startDate;
    todoEventCopy.endDate = self.endDate;
    todoEventCopy.date = self.date;
    
    todoEventCopy.position = self.position;
    
    todoEventCopy.completed = self.completed;
    todoEventCopy.allDay = self.allDay;
    
    return todoEventCopy;
}

@end
