//
//  NSDate+VIKKit.m
//  Daily
//
//  Created by Viktor Fröberg on 09/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "NSDate+VIKKit.h"

#define D_DAY		86400

static const unsigned componentFlags = (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal);

@implementation NSDate (VIKKit)

+ (NSCalendar *)currentCalendar
{
    static NSCalendar *sharedCalendar = nil;
    if (!sharedCalendar)
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    return sharedCalendar;
}

+ (NSArray *)datesBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSInteger dateRangeInDays = [startDate daysBeforeDate:endDate] + 1;
    return [@(dateRangeInDays) arrayByMapping:^NSDate *(NSNumber *number) {
        return [startDate dateByAddingDays:number.integerValue];
    }];
}

+ (NSDate *)dateWithDaysFromNow:(NSInteger) days
{
    return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate *)dateWithDaysBeforeNow:(NSInteger) days
{
    return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate *)dateTomorrow
{
    return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *)dateYesterday
{
    return [NSDate dateWithDaysBeforeNow:1];
}

- (BOOL)isEqualToDateIgnoringTime:(NSDate *) aDate
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:componentFlags fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day));
}

- (NSDate *)startOfDay
{
    NSDateComponents *components = [self dateComponents];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    return [[NSDate currentCalendar] dateFromComponents:components];
}

- (NSDate *)endOfDay
{
    NSDateComponents *components = [self dateComponents];
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    
    return [[NSDate currentCalendar] dateFromComponents:components];
}

- (BOOL)isToday
{
    return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL)isTomorrow
{
    return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

- (BOOL)isYesterday
{
    return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
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

- (BOOL)isInFuture
{
    return ([self isAfterDate:[NSDate date]]);
}

- (BOOL)isInPast
{
    return ([self isBeforeDate:[NSDate date]]);
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
    return [self dateByAddingDays: (days * -1)];
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

#pragma mark - Private

- (NSDateComponents *)dateComponents
{
    NSCalendar *calendar = [NSDate currentCalendar];
    NSDateComponents *dateComponents = [calendar components:componentFlags fromDate:self];
    return dateComponents;
}

@end
