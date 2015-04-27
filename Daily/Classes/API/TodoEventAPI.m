//
//  TodoEventAPI.m
//  Daily
//
//  Created by Viktor Fröberg on 25/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "TodoEventAPI.h"

#import <EventKit/EventKit.h>

#import "EKCalendar+VFDaily.h"
#import "Todo+Extended.h"

#define R_Either(left, right) left ? left : right

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(todoStoreDidChange:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EKEventStoreChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
}


#pragma mark - Observer callbacks

- (void)eventStoreDidChange:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TodoEventAPIDidChangeNotification object:self];
}

- (void)todoStoreDidChange:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TodoEventAPIDidChangeNotification object:self];
}


#pragma mark - Public methods

- (void)createTodoEventWithTitle:(NSString *)title startDate:(NSDate *)startDate endDate:(NSDate *)endDate allDay:(BOOL)allDay completion:(TodoEventClientItemBlock)completion
{
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    event.calendar = [self.eventStore defaultCalendarForNewEvents];
    event.title = title;
    event.startDate = startDate;
    event.endDate = endDate;
    event.allDay = allDay;
    
    NSError *error;
    [self.eventStore saveEvent:event span:EKSpanThisEvent error:&error];
    
    TodoEvent *todoEvent = [[TodoEvent alloc] initWithDictionary:@{@"title": event.title,
                                                                   @"startDate": event.startDate,
                                                                   @"endDate": event.endDate,
                                                                   @"allDay": @(allDay),
                                                                   @"completed": @(NO),
                                                                   @"date": [event.startDate startOfDay]} error:nil];
    
    if (completion) completion(error, todoEvent);
}

- (void)fetchTodoEventWithTodoEventIdentifier:(NSString *)todoEventIdentifier completion:(TodoEventClientItemBlock)completion
{
    NSDate *date = [TodoEvent dateFromTodoEventIdentifier:todoEventIdentifier];
    [self fetchTodoEventsWithStartDate:[date startOfDay] endDate:[date endOfDay] completion:^(NSError *error, NSArray *todoEvents) {
        TodoEvent *todoEvent = [todoEvents find:^BOOL(TodoEvent *todoEvent) {
            return [todoEvent.todoEventIdentifier isEqual:todoEventIdentifier];
        }];
        if (completion) completion(error, todoEvent);
    }];
}

- (void)fetchTodoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate completion:(TodoEventClientCollectionBlock)completion
{
    __block NSArray *todoEvents = @[];
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        
        if (!granted || error) return completion(error, nil);
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            
            NSArray *events = [self eventsWithStartDate:startDate endDate:endDate];
            todoEvents = [events flatArrayByMapping:^NSArray *(EKEvent *event) {
                NSArray *endDates = @[event.endDate, endDate];
                NSDate *minEndDate = [endDates valueForKeyPath:@"@min.self"];
                NSArray *dates = [NSDate datesBetweenStartDate:event.startDate endDate:minEndDate];
                NSArray *todos = [dates arrayByMapping:^Todo *(NSDate *date) {
                    return [Todo findOrCreateWithEvent:event date:date inContext:localContext];
                }];
                return [todos arrayByMapping:^TodoEvent *(Todo *todo) {
                    return [[TodoEvent alloc] initWithDictionary:@{@"title": event.title,
                                                                   @"startDate": event.startDate,
                                                                   @"endDate": event.endDate,
                                                                   @"allDay": @(event.allDay),
                                                                   @"location": R_Either(event.location, @""),
                                                                   @"notes": R_Either(event.notes, @""),
                                                                   @"url": R_Either(event.URL.absoluteString, @""),
                                                                   @"date": [todo.date startOfDay],
                                                                   @"completed": [todo.completed copy],
                                                                   @"position": [todo.position copy],
                                                                   @"todoEventIdentifier": [todo.todoIdentifier copy]} error:nil];
                }];
            }];
            
        } completion:^(BOOL success, NSError *error) {
            completion(error, todoEvents);
        }];
        
    }];
    
}

- (void)updateTodoEvents:(NSArray *)todoEvents completion:(TodoEventClientNoneBlock)completion
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [todoEvents enumerateObjectsUsingBlock:^(TodoEvent *todoEvent, NSUInteger index, BOOL *stop) {
            Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier" withValue:todoEvent.todoEventIdentifier inContext:localContext];
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
        Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier" withValue:todoEvent.todoEventIdentifier inContext:localContext];
        todo.position = [NSNumber numberWithInteger:todoEvent.position];
        todo.completed = [NSNumber numberWithBool:todoEvent.completed];
    } completion:^(BOOL success, NSError *error) {
        [self updateEventWithTodoEvent:todoEvent];
        if (completion) completion(error);
    }];
}

- (void)uncompleteTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier" withValue:todoEvent.todoEventIdentifier inContext:localContext];
        todo.completed = [NSNumber numberWithBool:!todoEvent.completed];
    } completion:^(BOOL success, NSError *error) {
        if (completion) completion(error);
    }];
}

- (void)completeTodoEvent:(TodoEvent *)todoEvent completion:(TodoEventClientNoneBlock)completion
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Todo *todo = [Todo findFirstByAttribute:@"todoIdentifier" withValue:todoEvent.todoEventIdentifier inContext:localContext];
        todo.completed = [NSNumber numberWithBool:!todoEvent.completed];
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
    NSArray *events = [self eventsWithStartDate:[todoEvent.date startOfDay] endDate:[todoEvent.date endOfDay]];
    
    return [events find:^BOOL(EKEvent *event) {
        return [event.eventIdentifier isEqual:todoEvent.eventIdentifier];
    }];
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

@implementation TodoEventAPI (RAC)

- (RACSignal *)rac_todoEventAPIDidChangeNotification
{
    return [RACSignal merge:@[[RACSignal return:nil], [[NSNotificationCenter defaultCenter] rac_addObserverForName:TodoEventAPIDidChangeNotification object:self]]];
}

- (RACSignal *)rac_fetchTodoEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    return [[self rac_todoEventAPIDidChangeNotification] flattenMap:^RACStream *(id value) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [self fetchTodoEventsWithStartDate:startDate endDate:endDate completion:^(NSError *error, NSArray *todoEvents) {
                if (error) {
                    [subscriber sendError:error];
                } else {
                    [subscriber sendNext:todoEvents];
                    [subscriber sendCompleted];
                }
            }];
            return nil;
        }];
    }];
}

@end
