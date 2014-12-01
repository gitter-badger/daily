//
//  NSDateFormatter+Extended.h
//  Daily
//
//  Created by Viktor Fröberg on 03/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Extended)

+ (NSDateFormatter *)weekNumberFormatter;
+ (NSDateFormatter *)monthFormatter;
+ (NSDateFormatter *)timeFormatter;
+ (NSDateFormatter *)fullDateFormatter;
+ (NSDateFormatter *)compactFullDateFormat;
+ (NSDateFormatter *)relativeDateFormatter;
+ (NSDateFormatter *)relativeWeekDayFormatterFromDate:(NSDate *)date;
+ (NSDateFormatter *)relativeDayFormatter;
+ (NSDateFormatter *)weekdayFormatter;

@end
