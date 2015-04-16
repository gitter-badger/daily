//
//  TodoEventActions.m
//  Daily
//
//  Created by Viktor Fröberg on 30/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "TodoEventActions.h"
#import "TodoEventAPI.h"
#import "Dispatcher.h"

@interface TodoEventActions ()

@property (nonatomic, strong) TodoEventAPI *client;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@end

@implementation TodoEventActions

+ (id)sharedActions {
    static TodoEventActions *sharedActions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedActions = [[self alloc] init];
    });
    return sharedActions;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.client = [[TodoEventAPI alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(todoEventClientDidChange:) name:TodoEventAPIDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TodoEventAPIDidChangeNotification object:nil];
}

- (void)todoEventClientDidChange:(NSNotification *)notificaiton
{
    [self loadTodoEvents];
}

- (void)loadTodoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    self.startDate = startDate;
    self.endDate = endDate;
    
    [self loadTodoEvents];
}

- (void)loadTodoEvents
{
    [self.client fetchTodoEventsWithStartDate:self.startDate endDate:self.endDate completion:^(NSError *error, NSArray *todoEvents) {
        if (error) {
            [[Dispatcher sharedDispatcher] dispatch:@{@"actionType": @"LOAD_TODOEVENTS_FAIL", @"error": error}];
        } else {
            [[Dispatcher sharedDispatcher] dispatch:@{@"actionType": @"LOAD_TODOEVENTS_SUCCESS", @"todoEvents": todoEvents}];
        }
    }];
}

- (void)createTodoEvent:(TodoEvent *)todoEvent
{
    [self.client createTodoEvent:todoEvent completion:^(NSError *error) {
        [self handleChange:error];
    }];
}

- (void)deleteThisTodoEvent:(TodoEvent *)todoEvent
{
    [self.client deleteThisTodoEvent:todoEvent completion:^(NSError *error) {
        [self handleChange:error];
    }];
}

- (void)deleteFutureTodoEvent:(TodoEvent *)todoEvent
{
    [self.client deleteFutureTodoEvent:todoEvent completion:^(NSError *error) {
        [self handleChange:error];
    }];
}

- (void)updateTodoEvent:(TodoEvent *)todoEvent
{
    [self.client updateTodoEvent:todoEvent completion:^(NSError *error) {
        [self handleChange:error];
    }];
}

- (void)updateTodoEvents:(NSArray *)todoEvents
{
    [self.client updateTodoEvents:todoEvents completion:^(NSError *error) {
        [self handleChange:error];
    }];
}

- (void)completeTodoEvent:(TodoEvent *)todoEvent
{
    [self.client completeTodoEvent:todoEvent completion:^(NSError *error) {
        [self handleChange:error];
    }];
}

- (void)uncompleteTodoEvent:(TodoEvent *)todoEvent
{
    [self.client uncompleteTodoEvent:todoEvent completion:^(NSError *error) {
        [self handleChange:error];
    }];
}

- (void)handleChange:(NSError *)error
{
    if (error) {
        [self handleError:error];
    } else {
        [self loadTodoEvents];
    }
}

- (void)handleError:(NSError *)error
{
    if (error) {
        NSLog(@"Error: %@", error);
    }
}

@end
