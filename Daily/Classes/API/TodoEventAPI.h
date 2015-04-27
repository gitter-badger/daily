//
//  TodoEventAPI.h
//  Daily
//
//  Created by Viktor Fröberg on 25/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TodoEvent.h"

typedef void (^TodoEventClientCollectionBlock)(NSError *error, NSArray *todoEvents);
typedef void (^TodoEventClientItemBlock)(NSError *error, TodoEvent *todoEvent);
typedef void (^TodoEventClientNoneBlock)(NSError *error);

extern NSString *const TodoEventAPIDidChangeNotification;

@interface TodoEventAPI : NSObject

+ (instancetype)sharedInstance;

- (void)createTodoEventWithTitle:(NSString *)title startDate:(NSDate *)startDate endDate:(NSDate *)endDate allDay:(BOOL)allDay completion:(TodoEventClientItemBlock)completion;

- (void)fetchTodoEventWithTodoEventIdentifier:(NSString *)todoEventIdentifier completion:(TodoEventClientItemBlock)completion;
- (void)fetchTodoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate completion:(TodoEventClientCollectionBlock)completion;

- (void)updateTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;
- (void)updateTodoEvents:(NSArray *)todoEvents completion:(TodoEventClientNoneBlock)completion;

- (void)completeTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;
- (void)uncompleteTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;

- (void)deleteThisTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;
- (void)deleteFutureTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion;

@end

@interface TodoEventAPI (RAC)

- (RACSignal *)rac_todoEventAPIDidChangeNotification;
- (RACSignal *)rac_fetchTodoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
