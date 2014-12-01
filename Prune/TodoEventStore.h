//
//  TodoEventStore.h
//  Daily
//
//  Created by Viktor Fröberg on 03/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TodoStore, TodoEvent, EKEventStore, EKEvent;

@interface TodoEventStore : NSObject

@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) TodoStore *todoStore;

+ (instancetype)sharedTodoEventStore;

- (instancetype)initWithEventStore:(EKEventStore *)eventStore todoStore:(TodoStore *)todoStore;

- (NSArray *)incompletedTodoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

- (NSArray *)todoEventsFromDate:(NSDate *)date calendars:(NSArray *)calendars;

- (NSArray *)incompletedTodoEventsFromDate:(NSDate *)date;

- (TodoEvent *)todoEventFromEvent:(EKEvent *)event day:(NSDate *)date;

- (void)save;

@end
