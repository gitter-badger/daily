//
//  TodoEventStore.m
//  Daily
//
//  Created by Viktor Fröberg on 25/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <EventKit/EventKit.h>

#import "TodoEventClient.h"

#import "EKCalendar+VFDaily.h"

#import "Todo+Extended.h"

@interface TodoEventClient ()

@property (nonatomic, strong) EKEventStore *eventStore;

@end

@implementation TodoEventClient

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.eventStore = [[EKEventStore alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreDidChange:) name:EKEventStoreChangedNotification object:self.eventStore];
    }
    return self;
}

- (void)eventStoreDidChange:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TodoEventClientDidChangeNotificaiton" object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EKEventStoreChangedNotification object:nil];
}


#pragma mark - Public methods

- (void)createTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    event.calendar = [self.eventStore defaultCalendarForNewEvents];
    event.title = todoEvent.title;
    event.location = todoEvent.location;
    event.startDate = todoEvent.startDate;
    event.endDate = todoEvent.endDate;
    event.allDay = todoEvent.allDay;
    
    NSError *error;
    [self.eventStore saveEvent:event span:EKSpanThisEvent error:&error];
    
    completion(error);
}

- (void)fetchTodoEventWithTodoEventIdentifier:(NSString *)todoEventIdentifier completion:(TodoEventClientItemBlock)completion
{
    NSDate *date = [MutableTodoEvent dateFromTodoEventIdentifier:todoEventIdentifier];
    [self fetchTodoEventsWithStartDate:[date startOfDay] endDate:[date endOfDay] completion:^(NSError *error, NSArray *todoEvents) {
        for (MutableTodoEvent *todoEvent in todoEvents) {
            if ([todoEvent.todoEventIdentifier isEqual:todoEventIdentifier]) {
                return completion(error, todoEvent);
            }
        }
        completion(error, nil);
    }];
}

- (void)fetchTodoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate completion:(TodoEventClientCollectionBlock)completion
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        
        if (!granted) return completion(error, nil);
        
        NSArray *events = [self eventsWithStartDate:startDate endDate:endDate];
        NSInteger fetchRangeDays = [startDate daysBeforeDate:endDate];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *context) {
            
            [events enumerateObjectsUsingBlock:^(EKEvent *event, NSUInteger index, BOOL *stop) {
                
                NSInteger eventRangeDays = [event.startDate daysBeforeDate:event.endDate];
                NSInteger days = fetchRangeDays < eventRangeDays ? fetchRangeDays : eventRangeDays;
                
                for (int i = 0; i <= days; i++) {
                    
                    NSDate *date = [[event.startDate dateByAddingDays:i] startOfDay];
                    NSString *todoIdentifier = [Todo todoIdentifierFromEventIdentifier:event.eventIdentifier date:date];
                    
                    Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier" withValue:todoIdentifier inContext:context];
                    if (!todo) {
                        todo = [Todo todoFromEvent:event forDate:date inContext:context];
                    }
                    
                }
            }];
            
        } completion:^(BOOL success, NSError *error) {
            
            NSMutableArray *todoEvents = [[NSMutableArray alloc] init];
            [events enumerateObjectsUsingBlock:^(EKEvent *event, NSUInteger index, BOOL *stop) {
                
                NSInteger eventRangeDays = [event.startDate daysBeforeDate:event.endDate];
                NSInteger days = fetchRangeDays < eventRangeDays ? fetchRangeDays : eventRangeDays;
                
                for (int i = 0; i <= days; i++) {
                    
                    NSDate *date = [[event.startDate dateByAddingDays:i] startOfDay];
                    NSString *todoIdentifier = [Todo todoIdentifierFromEventIdentifier:event.eventIdentifier date:date];
                    
                    MutableTodoEvent *todoEvent;
                    
                    Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier" withValue:todoIdentifier];
                    if (todo) {
                        todoEvent = [MutableTodoEvent todoEventFromTodo:todo event:event];
                        [todoEvents addObject:todoEvent];
                    }
                    
                }
            }];
            
            completion(error, todoEvents);
        }];
        
    }];
}

- (void)updateTodoEvents:(NSArray *)todoEvents completion:(TodoEventClientNoneBlock)completion
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [todoEvents enumerateObjectsUsingBlock:^(MutableTodoEvent *todoEvent, NSUInteger index, BOOL *stop) {
            Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier"
                                          withValue:todoEvent.todoEventIdentifier
                                          inContext:localContext];
            todo.position = [NSNumber numberWithInteger:todoEvent.position];
            todo.completed = [NSNumber numberWithBool:todoEvent.completed];
        }];
    } completion:^(BOOL success, NSError *error) {
        completion(error);
    }];
}

- (void)updateTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier"
                                      withValue:todoEvent.todoEventIdentifier
                                      inContext:localContext];
        todo.position = [NSNumber numberWithInteger:todoEvent.position];
        todo.completed = [NSNumber numberWithBool:todoEvent.completed];
    } completion:^(BOOL success, NSError *error) {
        [self updateEventWithTodoEvent:todoEvent];
        completion(error);
    }];
}

- (void)uncompleteTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    todoEvent.completed = NO;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier"
                                      withValue:todoEvent.todoEventIdentifier
                                      inContext:localContext];
        todo.completed = [NSNumber numberWithBool:todoEvent.completed];
    } completion:^(BOOL success, NSError *error) {
        completion(error);
    }];
}

- (void)completeTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    todoEvent.completed = YES;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier"
                                      withValue:todoEvent.todoEventIdentifier
                                      inContext:localContext];
        todo.completed = [NSNumber numberWithBool:todoEvent.completed];
    } completion:^(BOOL success, NSError *error) {
        completion(error);
    }];
}

- (void)deleteThisTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    EKEvent *event = [self eventFromTodoEvent:todoEvent];
    
    NSError *error;
    [self.eventStore removeEvent:event span:EKSpanThisEvent commit:YES error:&error];
    
    completion(error);
}

- (void)deleteFutureTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    EKEvent *event = [self eventFromTodoEvent:todoEvent];
    
    NSError *error;
    [self.eventStore removeEvent:event span:EKSpanFutureEvents commit:YES error:&error];
    
    completion(error);
}


#pragma mark - Private methods

- (NSArray *)eventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSArray *selectedCalendars = [EKCalendar calendarForEntityType:EKEntityTypeEvent];
    NSPredicate *storePredicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:selectedCalendars];
    return [self.eventStore eventsMatchingPredicate:storePredicate];
}

- (EKEvent *)eventFromTodoEvent:(MutableTodoEvent *)todoEvent
{
    return [self eventFromTodoEventIdentifier:todoEvent.todoEventIdentifier];
}

- (EKEvent *)eventFromTodoEventIdentifier:(NSString *)todoEventIdentifier
{
    NSString *eventIdentifier = [MutableTodoEvent eventIdentifierFromTodoEventIdentifier:todoEventIdentifier];
    NSDate *date = [MutableTodoEvent dateFromTodoEventIdentifier:todoEventIdentifier];
    
    NSArray *events = [self eventsWithStartDate:[date startOfDay] endDate:[date endOfDay]];
    for (EKEvent *localEvent in events) {
        if ([localEvent.eventIdentifier isEqual:eventIdentifier]) {
            return localEvent;
        }
    }
    
    return nil;
}

- (void)updateEventWithTodoEvent:(MutableTodoEvent *)todoEvent
{
    EKEvent *event = [self eventFromTodoEvent:todoEvent];
    
    event.title = todoEvent.title;
    event.notes = todoEvent.notes;
    event.location = todoEvent.location;
    event.URL = [NSURL URLWithString:todoEvent.url];
    
    NSError *error;
    [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
    NSLog(@"Error: %@", error);
}


@end
