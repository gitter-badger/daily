//
//  DAYTodoEvent.m
//  Daily
//
//  Created by Viktor Fröberg on 07/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "TodoEvent.h"

@implementation TodoEvent

#pragma mark - Mantle


#pragma mark - Class Methods

+ (NSDate *)dateFromTodoEventIdentifier:(NSString *)todoEventIdentifier
{
    NSString *dateString = [todoEventIdentifier substringFromIndex:todoEventIdentifier.length - 8];
    return [[TodoEvent dayMonthYearFormatter] dateFromString:dateString];
}

+ (NSString *)eventIdentifierFromTodoEventIdentifier:(NSString *)todoEventIdentifier
{
    return [todoEventIdentifier substringToIndex:todoEventIdentifier.length - 9];
}

+ (NSDateFormatter *)dayMonthYearFormatter
{
    static NSDateFormatter *dayMonthYearFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dayMonthYearFormatter = [[NSDateFormatter alloc] init];
        dayMonthYearFormatter.dateFormat = @"ddMMyyyy";
    });
    return dayMonthYearFormatter;
}

#pragma mark - Instance Methods

- (NSString *)eventIdentifier
{
    return [TodoEvent eventIdentifierFromTodoEventIdentifier:self.todoEventIdentifier];
}

- (BOOL)hasFutureEvents
{
    return NO;
}

#pragma mark - NSObject

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

@end
