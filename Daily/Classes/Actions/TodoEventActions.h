//
//  TodoEventActions.h
//  Daily
//
//  Created by Viktor Fröberg on 30/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MutableTodoEvent.h"

@class TodoEvent;

@interface TodoEventActions : NSObject

+ (instancetype)sharedActions;

- (void)loadTodoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

- (void)createTodoEvent:(MutableTodoEvent *)todoEvent;

- (void)updateTodoEvent:(MutableTodoEvent *)todoEvent;
- (void)updateTodoEvents:(NSArray *)todoEvents;

- (void)deleteThisTodoEvent:(MutableTodoEvent *)todoEvent;
- (void)deleteFutureTodoEvent:(MutableTodoEvent *)todoEvent;

- (void)completeTodoEvent:(MutableTodoEvent *)todoEvent;
- (void)uncompleteTodoEvent:(MutableTodoEvent *)todoEvent;

@end
