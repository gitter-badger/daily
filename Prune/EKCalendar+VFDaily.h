//
//  EKCalendar+VF.h
//  Daily
//
//  Created by Viktor Fröberg on 03/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <EventKit/EventKit.h>

@class Calendar;

@interface EKCalendar (VFDaily)

@property (nonatomic, strong) Calendar *calendar;

+ (NSArray *)calendarForEntityType:(EKEntityType)entityType;
+ (NSArray *)selectedCalendarForEntityType:(EKEntityType)entityType;

- (NSNumber *)isEnabled;
- (NSDate *)enabledDate;
- (void)setEnabledDate:(NSDate *)date;

@end
