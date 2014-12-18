//
//  TodoEventsCache.h
//  Daily
//
//  Created by Viktor Fröberg on 16/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TodoEvent;

@interface TodoEventsCache : NSObject

@property (nonatomic, strong) NSMutableArray *todoEvents;

- (void)performFetch;

- (NSUInteger)countOfTodoEvents; // REQUIRED

- (TodoEvent *)objectInTodoEventsAtIndex:(NSUInteger)index; // REQUIRED

- (void)insertObject:(TodoEvent *)object inTodoEventsAtIndex:(NSUInteger)index; // REQUIRED

- (void)removeObjectFromTodoEventsAtIndex:(NSUInteger)index; // REQUIRED

@end
