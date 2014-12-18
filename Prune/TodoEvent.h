//
//  TodoEvent.h
//  Daily
//
//  Created by Viktor Fröberg on 03/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKCalendar, EKEvent;

@interface TodoEvent : NSObject

// TODO: These two should be private...
@property (nonatomic, strong, readonly) EKEvent *event;
@property (nonatomic, strong, readonly) EKCalendar *calendar;

@property (nonatomic, strong, readonly) NSString *eventIdentifier;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSDate *startDate;
@property (nonatomic, strong, readonly) NSDate *endDate;
@property (nonatomic, strong, readonly) NSString *location;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *position;
@property (nonatomic, strong) NSNumber *completed;

- (NSString *)timeAgo;

- (BOOL)allDay;
- (BOOL)allowsContentModifications;
- (BOOL)deleteThisEvent;
- (BOOL)deleteFutureEvents;
- (BOOL)isCompleted;

- (BOOL)hasFutureEvents;

// Notifications (Cateogory?)
- (NSArray *)localNotifications;

// Helpers (View model?)
- (NSString *)humanReadableStartTime;
- (NSString *)humanReadableEndTime;

// Class methods
+ (NSArray *)findAllWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
+ (NSArray *)findAllIncompleteWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
+ (NSArray *)todoEventsFromEvent:(EKEvent *)event;

@end
