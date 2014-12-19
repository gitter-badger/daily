//
//  NSDate+VIKKit.h
//  Daily
//
//  Created by Viktor Fröberg on 09/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (VIKKit)

- (NSDate *)morning;
- (NSDate *)night;

- (NSDate *)yesterday;
- (NSDate *)tomorrow;

- (BOOL)isToday;
- (BOOL)isInFuture;
- (BOOL)isInPast;

- (BOOL)isBeforeDate:(NSDate *)date;
- (BOOL)isAfterDate:(NSDate *)date;

- (NSInteger)daysAfterDate:(NSDate *)date;
- (NSInteger)daysBeforeDate:(NSDate *)date;

- (NSDate *)dateByAddingDays:(NSInteger)days;
- (NSDate *)dateBySubtractingDays:(NSInteger)days;

@end
