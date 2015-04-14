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

- (void)deleteThisTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    EKEvent *event = [self eventFromTodoEvent:todoEvent];
    
    NSError *error;
    [self.eventStore removeEvent:event span:EKSpanThisEvent commit:YES error:&error];
    
    completion(error);
}

- (EKEvent *)eventFromTodoEvent:(MutableTodoEvent *)todoEvent
{
    NSArray *selectedCalendars = [EKCalendar calendarForEntityType:EKEntityTypeEvent];
    NSString *eventIdentifier = [self eventIdentifierFromTodoEventIdentifier:todoEvent.identifier];
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:[todoEvent.date startOfDay] endDate:[todoEvent.date endOfDay] calendars:selectedCalendars];
    NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
    __block EKEvent *event;

    [events enumerateObjectsUsingBlock:^(EKEvent *localEvent, NSUInteger index, BOOL *stop) {
        if ([localEvent.eventIdentifier isEqual:eventIdentifier] && [todoEvent.startDate isEqual:localEvent.startDate] && [todoEvent.endDate isEqual:localEvent.endDate]) {
            event = localEvent;
        }
    }];
    
    return event;
}

- (void)deleteFutureTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    EKEvent *event = [self eventFromTodoEvent:todoEvent];
    
    NSError *error;
    [self.eventStore removeEvent:event span:EKSpanFutureEvents commit:YES error:&error];
    
    completion(error);
}

- (void)updateTodoEvents:(NSArray *)todoEvents completion:(TodoEventClientNoneBlock)completion
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [todoEvents enumerateObjectsUsingBlock:^(MutableTodoEvent *todoEvent, NSUInteger index, BOOL *stop) {
            [self updateTodoEvent:todoEvent inContext:localContext];
        }];
    } completion:^(BOOL success, NSError *error) {
        completion(error);
    }];
}

- (void)updateTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [self updateTodoEvent:todoEvent inContext:localContext];
    } completion:^(BOOL success, NSError *error) {
        completion(error);
    }];
}

- (void)updateTodoEvent:(MutableTodoEvent *)todoEvent inContext:(NSManagedObjectContext *)context
{
    Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier"
                                  withValue:todoEvent.identifier
                                  inContext:context];
    
    todo.position = [NSNumber numberWithInteger:todoEvent.position];
    todo.completed = [NSNumber numberWithBool:todoEvent.completed];
}

- (void)uncompleteTodoEvent:(MutableTodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    todoEvent.completed = NO;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier"
                                      withValue:todoEvent.identifier
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
                                      withValue:todoEvent.identifier
                                      inContext:localContext];
        todo.completed = [NSNumber numberWithBool:todoEvent.completed];
    } completion:^(BOOL success, NSError *error) {
        completion(error);
    }];
}

- (NSString *)eventIdentifierFromTodoEventIdentifier:(NSString *)todoEventIdentifier
{
    return [todoEventIdentifier substringToIndex:todoEventIdentifier.length - 9]; // -yyyyMMdd
}

- (void)deleteThisTodoEventWithIdentifier:(NSString *)todoEventIdentifier
{
    NSString *eventIdentifier = [self eventIdentifierFromTodoEventIdentifier:todoEventIdentifier];
    EKEvent *event = [self.eventStore eventWithIdentifier:eventIdentifier];
    
    NSError *error;
    [self.eventStore removeEvent:event span:EKSpanThisEvent commit:YES error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    }
}

- (void)deleteFutureTodoEventsWithIdentifier:(NSString *)todoEventIdenfitifer
{
    // TODO: Implement
    NSLog(@"Error: Method not implemented yet.");
}

- (void)todoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate completion:(void (^)(NSArray *todoEvents, NSError *error))completion
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
       
        if (granted) {
            
            NSMutableArray *todoEvents = [[NSMutableArray alloc] init];
            
            NSArray *selectedCalendars = [EKCalendar calendarForEntityType:EKEntityTypeEvent];
            
            NSPredicate *storePredicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:selectedCalendars];
            
            NSArray *events = [self.eventStore eventsMatchingPredicate:storePredicate];
            
            NSInteger fetchRangeDays = [startDate daysBeforeDate:endDate];
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                
                [events enumerateObjectsUsingBlock:^(EKEvent *event, NSUInteger index, BOOL *stop) {
                    
                    NSInteger eventRangeDays = [event.startDate daysBeforeDate:event.endDate];
                    
                    NSInteger days = fetchRangeDays < eventRangeDays ? fetchRangeDays : eventRangeDays;
                    
                    for (int i = 0; i <= days; i++) {
                        
                        NSDate *date = [[event.startDate dateByAddingDays:i] startOfDay];
                        
                        NSString *todoIdentifier = [self todoIdentifierFromEventIdentifier:event.eventIdentifier date:date];
                        Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier" withValue:todoIdentifier inContext:localContext];
                        
                        if (!todo) {
                            todo = [Todo createInContext:localContext];
                            todo.date = date;
                            todo.position = @-1;
                            todo.todoIdentifier = todoIdentifier;
                            
                            NSDate *eventModifiedDate = [event.lastModifiedDate startOfDay];
                            NSDate *calendarEnabledDate = [[NSDate date] startOfDay]; //TODO: Refactor [event.calendar.enabledDate startOfDay];
                            NSDate *dayBeforeCalendarEnabledDate = [calendarEnabledDate dateBySubtractingDays:1];
                            
                            BOOL eventOccursAfterCalendarWasEnabled = [date isAfterDate:dayBeforeCalendarEnabledDate];
                            BOOL eventWasModifiedAfterCalendarWasEnabled = [eventModifiedDate isAfterDate:dayBeforeCalendarEnabledDate];
                            
                            if (eventOccursAfterCalendarWasEnabled || eventWasModifiedAfterCalendarWasEnabled) {
                                todo.completed = @NO;
                            } else {
                                todo.completed = @YES;
                            }
                        }
                        
                        NSString *url = [event.URL absoluteString];
                        
                        MutableTodoEvent *todoEvent = [[MutableTodoEvent alloc] init];
                        todoEvent.identifier = todo.todoIdentifier;
                        todoEvent.title = event.title;
                        todoEvent.allDay = event.allDay;
                        todoEvent.startDate = event.startDate;
                        todoEvent.endDate = event.endDate;
                        todoEvent.location = event.location;
                        todoEvent.completed = todo.completed.boolValue;
                        todoEvent.position = todo.position.integerValue;
                        todoEvent.date = todo.date;
                        todoEvent.notes = event.notes;
                        todoEvent.url = url;
                        
                        [todoEvents addObject:todoEvent];
                        
                    }
                }];
                
            } completion:^(BOOL success, NSError *error) {
                completion(todoEvents, error);
            }];
            
        } else {
            completion(@[], error);
        }
        
    }];
}

+ (NSDateFormatter *)dayMonthYearFormatter {
    static NSDateFormatter *dayMonthYearFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dayMonthYearFormatter = [[NSDateFormatter alloc] init];
        dayMonthYearFormatter.dateFormat = @"ddMMyyyy";
    });
    return dayMonthYearFormatter;
}

- (NSString *)todoIdentifierFromEventIdentifier:(NSString *)eventIdentifier date:(NSDate *)date;
{
    NSString *dateString = [[TodoEventClient dayMonthYearFormatter] stringFromDate:date];
    return [NSString stringWithFormat:@"%@-%@", eventIdentifier, dateString];
}

@end
