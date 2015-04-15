//
//  TodoEventActions.h
//  Daily
//
//  Created by Viktor Fröberg on 30/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TodoEvent.h"

@interface TodoEventActions : NSObject

+ (instancetype)sharedActions;

- (void)loadTodoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

- (void)createTodoEvent:(TodoEvent *)todoEvent;

- (void)updateTodoEvent:(TodoEvent *)todoEvent;
- (void)updateTodoEvents:(NSArray *)todoEvents;

- (void)deleteThisTodoEvent:(TodoEvent *)todoEvent;
- (void)deleteFutureTodoEvent:(TodoEvent *)todoEvent;

- (void)completeTodoEvent:(TodoEvent *)todoEvent;
- (void)uncompleteTodoEvent:(TodoEvent *)todoEvent;

@end
