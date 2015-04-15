//
//  TodoEventStore.h
//  Daily
//
//  Created by Viktor Fröberg on 25/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TodoEvent.h"

@protocol TodoEventClientDelegate;

typedef void (^TodoEventClientCollectionBlock)(NSError *error, NSArray *todoEvents);
typedef void (^TodoEventClientItemBlock)(NSError *error, TodoEvent *todoEvent);
typedef void (^TodoEventClientNoneBlock)(NSError *error);

@interface TodoEventAPI : NSObject

- (void)createTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;

- (void)fetchTodoEventWithTodoEventIdentifier:(NSString *)todoEventIdentifier completion:(TodoEventClientItemBlock)completion;
- (void)fetchTodoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate completion:(TodoEventClientCollectionBlock)completion;

- (void)updateTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;
- (void)updateTodoEvents:(NSArray *)todoEvents completion:(TodoEventClientNoneBlock)completion;

- (void)completeTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;
- (void)uncompleteTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;

- (void)deleteThisTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;
- (void)deleteFutureTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;

@end