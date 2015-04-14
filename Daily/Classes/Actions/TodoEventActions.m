//
//  TodoEventActions.m
//  Daily
//
//  Created by Viktor Fröberg on 30/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "TodoEventActions.h"
#import "TodoEventClient.h"
#import "Dispatcher.h"

@interface TodoEventActions ()

@property (nonatomic, strong) TodoEventClient *client;
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
        self.client = [[TodoEventClient alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(todoEventClientDidChange:) name:@"TodoEventClientDidChangeNotificaiton" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TodoEventClientDidChangeNotificaiton" object:nil];
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
    [self.client todoEventsWithStartDate:self.startDate endDate:self.endDate completion:^(NSArray *todoEvents, NSError *error) {
        if (error) {
            [[Dispatcher sharedDispatcher] dispatch:@{@"actionType": @"LOAD_TODOEVENTS_FAIL", @"error": error}];
        } else {
            [[Dispatcher sharedDispatcher] dispatch:@{@"actionType": @"LOAD_TODOEVENTS_SUCCESS", @"todoEvents": todoEvents}];
        }
    }];
}

- (void)createTodoEvent:(MutableTodoEvent *)todoEvent
{
    [self.client createTodoEvent:todoEvent completion:^(NSError *error) {
        [self handleChange:error];
    }];
}

- (void)deleteThisTodoEvent:(MutableTodoEvent *)todoEvent
{
    [self.client deleteThisTodoEvent:todoEvent completion:^(NSError *error) {
        [self handleChange:error];
    }];
}

- (void)deleteFutureTodoEvent:(MutableTodoEvent *)todoEvent
{
    [self.client deleteFutureTodoEvent:todoEvent completion:^(NSError *error) {
        [self handleChange:error];
    }];
}

- (void)updateTodoEvent:(MutableTodoEvent *)todoEvent
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

- (void)completeTodoEvent:(MutableTodoEvent *)todoEvent
{
    [self.client completeTodoEvent:todoEvent completion:^(NSError *error) {
        [self handleChange:error];
    }];
}

- (void)uncompleteTodoEvent:(MutableTodoEvent *)todoEvent
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
