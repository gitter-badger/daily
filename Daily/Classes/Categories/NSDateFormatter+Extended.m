//
//  NSDateFormatter+Extended.m
//  Daily
//
//  Created by Viktor Fröberg on 03/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "NSDateFormatter+Extended.h"

@implementation NSDateFormatter (Extended)

+ (NSDateFormatter *)weekNumberFormatter
{
    static NSDateFormatter *weekNumberFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        weekNumberFormatter = [[NSDateFormatter alloc] init];
        weekNumberFormatter.dateFormat = @"w";
    });
    return weekNumberFormatter;
}

+ (NSDateFormatter *)monthFormatter
{
    static NSDateFormatter *monthFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monthFormatter = [[NSDateFormatter alloc] init];
        monthFormatter.dateFormat = @"MMMM";
    });
    return monthFormatter;
}

+ (NSDateFormatter *)timeFormatter
{
    static NSDateFormatter *timeFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"jj:mm" options:0 locale:[NSLocale currentLocale]];
    });
    return timeFormatter;
}

+ (NSDateFormatter *)fullDateFormatter
{
    static NSDateFormatter *fullDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fullDateFormatter = [[NSDateFormatter alloc] init];
        [fullDateFormatter setDateFormat: @"d MMMM YYYY', W'w"];
    });
    return fullDateFormatter;
}

+ (NSDateFormatter *)compactFullDateFormat {
    static NSDateFormatter *compactFullDateFormat;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        compactFullDateFormat = [[NSDateFormatter alloc] init];
        compactFullDateFormat.dateFormat = @"ddMMyyyy";
    });
    return compactFullDateFormat;
}

+ (NSDateFormatter *)relativeWeekDayFormatterFromDate:(NSDate *)date
{
    if ([date isToday] || [date isTomorrow] || [date isYesterday]) {
        return [self relativeDayFormatter];
    } else {
        return [self weekdayFormatter];
    }
}

+ (NSDateFormatter *)relativeDateFormatter
{
    static NSDateFormatter *relativeDayFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        relativeDayFormatter = [[NSDateFormatter alloc] init];
        relativeDayFormatter.dateStyle = NSDateFormatterFullStyle;
        relativeDayFormatter.timeStyle = NSDateFormatterNoStyle;
        relativeDayFormatter.doesRelativeDateFormatting = YES;
    });
    return relativeDayFormatter;
}

+ (NSDateFormatter *)relativeDayFormatter
{
    static NSDateFormatter *relativeDayFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        relativeDayFormatter = [[NSDateFormatter alloc] init];
        relativeDayFormatter.dateStyle = NSDateFormatterLongStyle;
        relativeDayFormatter.timeStyle = NSDateFormatterNoStyle;
        relativeDayFormatter.doesRelativeDateFormatting = YES;
    });
    return relativeDayFormatter;
}

+ (NSDateFormatter *)relativeDayTimeFormatter
{
    static NSDateFormatter *relativeDayTimeFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        relativeDayTimeFormatter = [[NSDateFormatter alloc] init];
        relativeDayTimeFormatter.dateStyle = NSDateFormatterLongStyle;
        relativeDayTimeFormatter.timeStyle = NSDateFormatterShortStyle;
        relativeDayTimeFormatter.doesRelativeDateFormatting = YES;
    });
    return relativeDayTimeFormatter;
}

+ (NSDateFormatter *)weekdayFormatter
{
    static NSDateFormatter *weekdayFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        weekdayFormatter = [[NSDateFormatter alloc] init];
        [weekdayFormatter setDateFormat: @"EEEE"];
    });
    return weekdayFormatter;
}

@end
