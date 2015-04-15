//
//  TodoEventStore.h
//  Daily
//
//  Created by Viktor Fröberg on 25/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MutableTodoEvent.h"

@protocol TodoEventClientDelegate;

typedef void (^TodoEventClientCollectionBlock)(NSError *error, NSArray *todoEvents);
typedef void (^TodoEventClientItemBlock)(NSError *error, MutableTodoEvent *todoEvent);
typedef void (^TodoEventClientNoneBlock)(NSError *error);

@interface TodoEventClient : NSObject

- (void)createTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;

- (void)fetchTodoEventWithTodoEventIdentifier:(NSString *)todoEventIdentifier completion:(TodoEventClientItemBlock)completion;
- (void)fetchTodoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate completion:(TodoEventClientCollectionBlock)completion;

- (void)updateTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;
- (void)updateTodoEvents:(NSArray *)todoEvents completion:(TodoEventClientNoneBlock)completion;

- (void)completeTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;
- (void)uncompleteTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;

- (void)deleteThisTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;
- (void)deleteFutureTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;

@end
