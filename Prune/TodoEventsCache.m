//
//  TodoEventsCache.m
//  Daily
//
//  Created by Viktor Fröberg on 16/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "TodoEventsCache.h"
#import "TodoEvent.h"
#import "EKEventStore+VFDaily.h"

@interface TodoEventsCache ()

@end

@implementation TodoEventsCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.todoEvents = [NSMutableArray array];
        [self performFetch];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(todoEventCompleted:) name:@"TodoEventCompleted" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(todoEventUncompleted:) name:@"TodoEventUncompleted" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChanged:) name:EKEventStoreChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TodoEventCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TodoEventUncompleted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EKEventStoreChangedNotification object:nil];
}

- (void)eventStoreChanged:(NSNotification *)notification
{
    [self performFetch];
}

- (void)todoEventCompleted:(NSNotification *)notification
{
    [self performFetch];
//    TodoEvent *todoEvent = notification.object;
//    if ([self.todoEvents containsObject:todoEvent]) {
//        NSMutableArray *newTodoEvents = [self.todoEvents mutableCopy];
//        [newTodoEvents removeObject:todoEvent];
//        self.todoEvents = [[self sortedTodoEvents:newTodoEvents] mutableCopy];
//    }
}

- (void)todoEventUncompleted:(NSNotification *)notification
{
    [self performFetch];
//    TodoEvent *todoEvent = notification.object;
//    NSMutableArray *newTodoEvents = [self.todoEvents mutableCopy];
//    [newTodoEvents addObject:todoEvent];
//    self.todoEvents = [[self sortedTodoEvents:newTodoEvents] mutableCopy];
}

- (NSUInteger)countOfTodoEvents
{
    return self.todoEvents.count;
}

- (TodoEvent *)objectInTodoEventsAtIndex:(NSUInteger)index
{
    return [self.todoEvents objectAtIndex:index];
}

- (void)insertObject:(TodoEvent *)object inTodoEventsAtIndex:(NSUInteger)index
{
    [self.todoEvents insertObject:object atIndex:index];
}

- (void)removeObjectFromTodoEventsAtIndex:(NSUInteger)index
{
    [self.todoEvents removeObjectAtIndex:index];
}

- (NSArray *)sortedTodoEvents:(NSArray *)todoEvents
{
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSSortDescriptor *positionSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
    return [todoEvents sortedArrayUsingDescriptors:@[dateSortDescriptor, positionSortDescriptor]];
}

- (void)performFetch
{
    [[EKEventStore sharedEventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDate *endDate = [[[NSDate date ] yesterday] night];
                NSDate *startDate = [endDate dateBySubtractingDays:14];
                NSArray *todoEvents = [TodoEvent findAllIncompleteWithStartDate:startDate endDate:endDate];
                self.todoEvents = [[self sortedTodoEvents:todoEvents] mutableCopy];
            });
        }
    }];
}

@end
