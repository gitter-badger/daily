//
//  TodoEventStore.m
//  Daily
//
//  Created by Viktor Fröberg on 03/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <EventKit/EventKit.h>

// Stores
#import "SettingsStore.h"
#import "TodoEventStore.h"
#import "TodoStore.h"

// Models
#import "Todo.h"
#import "TodoEvent.h"

// Categories
#import "NSDateFormatter+Extended.h"
#import "NSDate+Utilities.h"

@interface TodoEventStore ()

@end

@implementation TodoEventStore

+ (instancetype)sharedTodoEventStore
{
    static TodoEventStore *sharedTodoEventStore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TodoStore *todoStore = [[TodoStore alloc] init];
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        sharedTodoEventStore = [[TodoEventStore alloc] initWithEventStore:eventStore todoStore:todoStore];
    });
    return sharedTodoEventStore;
}

- (instancetype)initWithEventStore:(EKEventStore *)eventStore todoStore:(TodoStore *)todoStore
{
    self = [super init];
    
    if (self) {
        self.eventStore = eventStore;
        self.todoStore = todoStore;
    }
    
    return self;
}

//- (void)migrateTodos
//{
//    NSArray *todos = [self todos];
//    for (Todo *todo in todos) {
//        if (todo.todoIdentifier) {
//            NSString *dateString = [todo.todoIdentifier substringFromIndex:todo.todoIdentifier.length - 8];
//            NSDate *date = [[NSDateFormatter compactFullDateFormat] dateFromString:dateString];
//            NSString *eventIdentifier = [todo.todoIdentifier substringToIndex:todo.todoIdentifier.length - 8];
//
//            todo.date = date;
//            todo.eventIdentifier = eventIdentifier;
//        }
//    }
//}

- (NSArray *)todoEventsFromDate:(NSDate *)date calendars:(NSArray *)calendars
{
    NSDate *startOfDay = [date dateAtStartOfDay];
    NSDate *endOfDay = [date dateAtEndOfDay];

    NSPredicate *allDayPredicate = [self.eventStore predicateForEventsWithStartDate:startOfDay
                                                                       endDate:endOfDay
                                                                     calendars:calendars];
    NSArray *todoEvents = [self todoEventsMatchingPredicate:allDayPredicate day:startOfDay];
    
    NSSortDescriptor *positionSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
    todoEvents = [todoEvents sortedArrayUsingDescriptors:@[positionSortDescriptor]];
    
    return todoEvents;
}

- (NSArray *)todoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate calendars:(NSArray *)calendars
{
    NSMutableArray *todoEvents = [NSMutableArray array];
    NSInteger daysBetween = [startDate daysBeforeDate:endDate];
    for (int i = 0; i < daysBetween; i++) {
        NSDate *date = [startDate dateByAddingDays:i];
        NSArray *newTodoEvents = [self incompletedTodoEventsFromDate:date];
        [todoEvents addObjectsFromArray:newTodoEvents];
    }
    return todoEvents;
}

- (NSArray *)incompletedTodoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSArray *calendars = [[SettingsStore sharedSettingsStore] calendars];
    if (calendars.count) {
        NSArray *events = [self todoEventsWithStartDate:startDate endDate:endDate calendars:calendars];
        NSPredicate *incompletedPredicate = [NSPredicate predicateWithFormat:@"completed = %@", @NO];
        return [events filteredArrayUsingPredicate:incompletedPredicate];
    } else {
        return @[];
    }
}

- (NSArray *)incompletedTodoEventsFromDate:(NSDate *)date
{
    NSArray *calendars = [[SettingsStore sharedSettingsStore] calendars];
    if (calendars.count) {
        NSArray *events = [self todoEventsFromDate:date calendars:calendars];
        NSPredicate *incompletedPredicate = [NSPredicate predicateWithFormat:@"completed = %@", @NO];
        return [events filteredArrayUsingPredicate:incompletedPredicate];
    } else {
        return @[];
    }
}

- (TodoEvent *)todoEventFromEvent:(EKEvent *)event day:(NSDate *)date
{
    NSArray *todos = [self todosMatchingEvents:@[event] day:date];
    NSArray *todoEvents = [self todoEventsFromEvents:@[event] todos:todos day:date];
    if (todoEvents && todoEvents.count) {
        return [todoEvents lastObject];
    }
    return nil;
}

- (void)save
{
    [self.todoStore save];
}

#pragma mark - Private

- (NSArray *)todoEventsMatchingPredicate:(NSPredicate *)predicate day:(NSDate *)date
{
    NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
    NSArray *todos = [self todosMatchingEvents:events day:date];
    
    return [self todoEventsFromEvents:events todos:todos day:date];
}

- (NSArray *)todoEventsFromEvents:(NSArray *)events todos:(NSArray *)todos day:(NSDate *)date
{
    NSMutableArray *todoEvents = [[NSMutableArray alloc] initWithCapacity:events.count];
    [events enumerateObjectsUsingBlock:^(EKEvent *event, NSUInteger idx, BOOL *stop) {
        NSString *todoIdentifier = [self todoIdentifierFromEvent:event day:date];
        Todo *todo = [self todoMatchingTodoIdentifier:todoIdentifier within:todos];
        if (!todo) {
            todo = [Todo insertNewObjectIntoContext:self.todoStore.managedObjectContext];
            todo.todoIdentifier = todoIdentifier;
            todo.position = @-1;
        }
        TodoEvent *todoEvent = [[TodoEvent alloc] initWithEvent:event todo:todo];
        [todoEvents addObject:todoEvent];
    }];
    
    return todoEvents;
}

- (Todo *)todoMatchingTodoIdentifier:(NSString *)todoIdentifier within:(NSArray *)todos
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"todoIdentifier = %@", todoIdentifier];
    NSArray *todosMatchingTodoIdentifier = [todos filteredArrayUsingPredicate:predicate];
    return [todosMatchingTodoIdentifier firstObject];
}

- (NSArray *)todosMatchingEvents:(NSArray *)events day:(NSDate *)date
{
    NSArray *todoIdentifiers = [self todoIdentifiersFromEvents:events day:date];
    return [self todosMatchingTodoIdentifiers:todoIdentifiers];
}

- (NSArray *)todosMatchingTodoIdentifiers:(NSArray *)todoIdentifiers
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[Todo entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"todoIdentifier IN %@", todoIdentifiers];
    request.predicate = predicate;
    
    NSError *error;
    NSArray *todos = [self.todoStore.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"error: %@", error);
    }
    
    return todos;
}

- (NSArray *)todoIdentifiersFromEvents:(NSArray *)events day:(NSDate *)date
{
    NSMutableArray *todoIdentifiers = [NSMutableArray arrayWithCapacity:events.count];
    [events enumerateObjectsUsingBlock:^(EKEvent *event, NSUInteger idx, BOOL *stop) {
        [todoIdentifiers addObject:[self todoIdentifierFromEvent:event day:date]];
    }];
    return todoIdentifiers;
}

- (NSString *)todoIdentifierFromEvent:(EKEvent *)event day:(NSDate *)date
{
    return [NSString stringWithFormat:@"%@%@", event.eventIdentifier, [[NSDateFormatter compactFullDateFormat] stringFromDate:date]];
}

@end
