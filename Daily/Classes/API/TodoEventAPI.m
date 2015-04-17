//
//  TodoEventStore.m
//  Daily
//
//  Created by Viktor Fröberg on 25/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "TodoEventAPI.h"

#import <EventKit/EventKit.h>

#import "EKCalendar+VFDaily.h"
#import "Todo+Extended.h"


NSString *const TodoEventAPIDidChangeNotification = @"TodoEventAPIDidChangeNotification";

@interface TodoEventAPI ()

@property (nonatomic, strong) EKEventStore *eventStore;

@end


@implementation TodoEventAPI

#pragma mark - Life cycle

+ (instancetype)sharedInstance
{
    static TodoEventAPI *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstace = [[self alloc] init];
    });
    return sharedInstace;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.eventStore = [[EKEventStore alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreDidChange:) name:EKEventStoreChangedNotification object:self.eventStore];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(todoStoreDidChange:) name:NSManagedObjectContextDidSaveNotification object:[NSManagedObjectContext defaultContext]];
    }
    return self;
}

- (void)eventStoreDidChange:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TodoEventAPIDidChangeNotification object:self];
}

- (void)todoStoreDidChange:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TodoEventAPIDidChangeNotification object:self];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EKEventStoreChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
}


#pragma mark - Public methods

- (void)createTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
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
    
    if (completion) completion(error);
}

- (void)fetchTodoEventWithTodoEventIdentifier:(NSString *)todoEventIdentifier completion:(TodoEventClientItemBlock)completion
{
    NSDate *date = [TodoEvent dateFromTodoEventIdentifier:todoEventIdentifier];
    [self fetchTodoEventsWithStartDate:[date startOfDay] endDate:[date endOfDay] completion:^(NSError *error, NSArray *todoEvents) {
        for (TodoEvent *todoEvent in todoEvents) {
            if ([todoEvent.todoEventIdentifier isEqual:todoEventIdentifier]) {
                return completion(error, todoEvent);
            }
        }
        if (completion) completion(error, nil);
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
                    
                    TodoEvent *todoEvent;
                    
                    Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier" withValue:todoIdentifier];
                    if (todo) {
                        todoEvent = [TodoEvent todoEventFromTodo:todo event:event];
                        [todoEvents addObject:todoEvent];
                    }
                    
                }
            }];
            
            if (completion) completion(error, todoEvents);
        }];
        
    }];
}

- (void)updateTodoEvents:(NSArray *)todoEvents completion:(TodoEventClientNoneBlock)completion
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [todoEvents enumerateObjectsUsingBlock:^(TodoEvent *todoEvent, NSUInteger index, BOOL *stop) {
            Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier"
                                          withValue:todoEvent.todoEventIdentifier
                                          inContext:localContext];
            todo.position = [NSNumber numberWithInteger:todoEvent.position];
            todo.completed = [NSNumber numberWithBool:todoEvent.completed];
        }];
    } completion:^(BOOL success, NSError *error) {
        if (completion) completion(error);
    }];
}

- (void)updateTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier"
                                      withValue:todoEvent.todoEventIdentifier
                                      inContext:localContext];
        todo.position = [NSNumber numberWithInteger:todoEvent.position];
        todo.completed = [NSNumber numberWithBool:todoEvent.completed];
    } completion:^(BOOL success, NSError *error) {
        [self updateEventWithTodoEvent:todoEvent];
        if (completion) completion(error);
    }];
}

- (void)uncompleteTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    todoEvent.completed = NO;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier"
                                      withValue:todoEvent.todoEventIdentifier
                                      inContext:localContext];
        todo.completed = [NSNumber numberWithBool:todoEvent.completed];
    } completion:^(BOOL success, NSError *error) {
        if (completion) completion(error);
    }];
}

- (void)completeTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    todoEvent.completed = YES;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier"
                                      withValue:todoEvent.todoEventIdentifier
                                      inContext:localContext];
        todo.completed = [NSNumber numberWithBool:todoEvent.completed];
    } completion:^(BOOL success, NSError *error) {
        if (completion) completion(error);
    }];
}

- (void)deleteThisTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    EKEvent *event = [self eventFromTodoEvent:todoEvent];
    
    NSError *error;
    [self.eventStore removeEvent:event span:EKSpanThisEvent commit:YES error:&error];
    
    if (completion) completion(error);
}

- (void)deleteFutureTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    EKEvent *event = [self eventFromTodoEvent:todoEvent];
    
    NSError *error;
    [self.eventStore removeEvent:event span:EKSpanFutureEvents commit:YES error:&error];
    
    if (completion) completion(error);
}


#pragma mark - Private methods

- (NSArray *)eventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSArray *selectedCalendars = [EKCalendar calendarForEntityType:EKEntityTypeEvent];
    NSPredicate *storePredicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:selectedCalendars];
    return [self.eventStore eventsMatchingPredicate:storePredicate];
}

- (EKEvent *)eventFromTodoEvent:(TodoEvent *)todoEvent
{
    return [self eventFromTodoEventIdentifier:todoEvent.todoEventIdentifier];
}

- (EKEvent *)eventFromTodoEventIdentifier:(NSString *)todoEventIdentifier
{
    NSString *eventIdentifier = [TodoEvent eventIdentifierFromTodoEventIdentifier:todoEventIdentifier];
    NSDate *date = [TodoEvent dateFromTodoEventIdentifier:todoEventIdentifier];
    
    NSArray *events = [self eventsWithStartDate:[date startOfDay] endDate:[date endOfDay]];
    for (EKEvent *localEvent in events) {
        if ([localEvent.eventIdentifier isEqual:eventIdentifier]) {
            return localEvent;
        }
    }
    
    return nil;
}

- (void)updateEventWithTodoEvent:(TodoEvent *)todoEvent
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
