//
//  NSDate+VIKKit.m
//  Daily
//
//  Created by Viktor Fröberg on 09/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "NSDate+VIKKit.h"

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

@implementation NSDate (VIKKit)

+ (NSDate *)tomorrow
{
    return [NSDate dateThatIsNumberOfDaysFromToday:1];
}

+ (NSDate *)yesterday
{
    return [NSDate dateThatIsNumberOfDaysFromToday:-1];
}

- (NSDate *)morning
{
    NSDateComponents *components = [self dateComponents];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    return [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:components];
}

- (NSDate *)night
{
    NSDateComponents *components = [self dateComponents];
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    
    return [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:components];
}

- (NSDate *)midnight
{
    NSDateComponents *components = [self dateComponents];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    return [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:components];
}

- (NSDate *)yesterday
{
    NSDateComponents *components = [self dateComponents];
    components.day -= 1;
    NSDate *date = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:components];
    return date;
}

- (NSDate *)tomorrow
{
    NSDateComponents *components = [self dateComponents];
    components.day += 1;
    NSDate *date = [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:components];
    return date;
}

- (BOOL)isToday
{
    if ([self compare:[NSDate yesterday]] == NSOrderedDescending && [self compare:[NSDate tomorrow]] == NSOrderedAscending)
        return YES;
    
    return NO;
}

- (BOOL)isInFuture
{
    return ([self isAfterDate:[NSDate date]]);
}

- (BOOL)isInPast
{
    return ([self isBeforeDate:[NSDate date]]);
}

- (BOOL)isBeforeDate:(NSDate *)date
{
    if ([self compare:date] == NSOrderedAscending || [self compare:date] == NSOrderedSame)
        return YES;
    
    return NO;
}

- (BOOL)isAfterDate:(NSDate *)date
{
    if ([self compare:date] == NSOrderedDescending || [self compare:date] == NSOrderedSame)
        return YES;
    
    return NO;
}

- (NSInteger)daysAfterDate:(NSDate *)date
{
    NSTimeInterval ti = [self timeIntervalSinceDate:date];
    return (NSInteger) (ti / D_DAY);
}

- (NSInteger)daysBeforeDate:(NSDate *)date
{
    NSTimeInterval ti = [date timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_DAY);
}

- (NSDate *)dateByAddingDays:(NSInteger)days
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:days];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *)dateBySubtractingDays:(NSInteger)days
{
    return [self dateByAddingDays:(days * -1)];
}

#pragma mark - Private

+ (NSDate *)dateThatIsNumberOfDaysFromToday:(NSInteger)numberOfDays
{
    NSDateComponents *components = [[NSDate date] dateComponents];
    components.day = components.day + numberOfDays;
    
    return [[NSCalendar autoupdatingCurrentCalendar] dateFromComponents:components];
}

- (NSDateComponents *)dateComponents
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger componentUnitFlags = (NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    NSDateComponents *dateComponents = [calendar components:componentUnitFlags fromDate:self];
    
    return dateComponents;
}

@end
