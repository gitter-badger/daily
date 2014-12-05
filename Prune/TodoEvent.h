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

@property(nonatomic, strong, readonly) EKEvent *event;

@property(nonatomic, strong, readonly) NSString *title;
@property(nonatomic, strong, readonly) NSDate *startDate;
@property(nonatomic, strong, readonly) NSDate *endDate;
@property(nonatomic, strong, readonly) NSString *location;
@property(nonatomic, strong, readonly) NSArray *recurrenceRules;
@property(nonatomic, strong, readonly) EKCalendar *calendar;

@property(nonatomic, strong) NSNumber *position;
@property(nonatomic, strong) NSNumber *completed;

- (BOOL)allDay;
- (BOOL)allowsContentModifications;
- (BOOL)deleteThisTodoEvent;
- (BOOL)deleteFutureTodoEvents;
- (BOOL)isCompleted;

// Notifications (Cateogory?)
- (NSArray *)localNotifications;

// Helpers (View model?)
- (NSString *)humanReadableStartTime;
- (NSString *)humanReadableEndTime;

// Class methods
+ (NSArray *)findAllWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
+ (NSArray *)findAllIncompleteWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
