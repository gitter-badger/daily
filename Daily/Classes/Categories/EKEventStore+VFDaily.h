//
//  EKEventStore+VFDaily.h
//  Daily
//
//  Created by Viktor Fröberg on 05/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <EventKit/EventKit.h>

@interface EKEventStore (VFDaily)

+ (instancetype)sharedEventStore;

//- (NSArray *)incompletedTodoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
//- (NSArray *)todoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
//
//- (NSArray *)selectedCalendars;

@end
