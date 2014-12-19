//
//  TodoEvent.m
//  Daily
//
//  Created by Viktor Fröberg on 03/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <EventKit/EventKit.h>

#import "Todo.h"
#import "TodoEvent.h"
#import "NSDateFormatter+Extended.h"
#import "EKEventStore+VFDaily.h"
#import "EKCalendar+VFDaily.h"

#import "VIKKit.h"

@interface TodoEvent()

@property (nonatomic, strong) EKCalendar *calendar;
@property (nonatomic, strong) EKEvent *event;
@property (nonatomic, strong) Todo *todo;

- (instancetype)initWithEvent:(EKEvent *)event todo:(Todo *)todo;

@end

@implementation TodoEvent

@dynamic startDate, endDate, calendar, location, title, eventIdentifier;

- (instancetype)initWithEvent:(EKEvent *)event todo:(Todo *)todo
{
    self = [super init];

    if (self) {
        self.event = event;
        self.todo = todo;
    }
    
    return self;
}

- (NSString *)timeAgo
{
    return [self.date timeAgo];
}

#pragma mark - Event delegation

- (NSString *)eventIdentifier
{
    return self.event.eventIdentifier;
}

- (NSString *)title
{
    return self.event.title;
}

- (NSDate *)startDate
{
    return self.event.startDate;
}

- (NSDate *)endDate
{
    return self.event.endDate;
}

- (NSString *)location
{
    return self.event.location;
}

- (NSArray *)recurrenceRules
{
    return self.event.recurrenceRules;
}

- (EKCalendar *)calendar
{
    return self.event.calendar;
}

- (BOOL)allDay
{
    return self.event.allDay;
}

- (BOOL)allowsContentModifications
{
    return self.event.calendar.allowsContentModifications;
}

- (BOOL)deleteThisEvent
{
    NSError* error;
    [[EKEventStore sharedEventStore] removeEvent:self.event span:EKSpanThisEvent error:&error];
    if (error) {
        NSLog(@"error: %@", error);
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)deleteFutureEvents
{
    NSError* error;
    [[EKEventStore sharedEventStore] removeEvent:self.event span:EKSpanFutureEvents error:&error];
    if (error) {
        NSLog(@"error: %@", error);
        return NO;
    } else {
        return YES;
    }
}

// TODO: Make smarter! What if last event?
- (BOOL)hasFutureEvents
{
    if (self.recurrenceRules.count) {
        return YES;
    }
    return NO;
}

#pragma mark - Todo delegation

- (NSDate *)date
{
    return self.todo.date;
}

- (void)setDate:(NSDate *)date
{
    self.todo.date = date;
}

- (NSNumber *)position
{
    return self.todo.position;
}

- (void)setPosition:(NSNumber *)position
{
    self.todo.position = position;
}

- (NSNumber *)completed
{
    return self.todo.completed;
}

- (void)setCompleted:(NSNumber *)completed
{
    self.todo.completed = completed;
    if (completed.boolValue) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TodoEventCompleted" object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TodoEventUncompleted" object:self];
    }
}

- (BOOL)isCompleted
{
    return self.completed.boolValue;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[TodoEvent class]]) {
        return NO;
    }
    
    return [self isEqualToTodoEvent:(TodoEvent *)object];
}

- (BOOL)isEqualToTodoEvent:(TodoEvent *)object
{
    BOOL equalEventIdentifier = [self.event.eventIdentifier isEqualToString:object.event.eventIdentifier];
    BOOL equalDate = [self.date isEqualToDate:object.date];
    if (equalEventIdentifier && equalDate) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSArray *)findAllWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    startDate = [startDate morning];
    endDate = [endDate night];
    EKEventStore *eventStore = [EKEventStore sharedEventStore];
    NSMutableArray *todoEvents = [[NSMutableArray alloc] init];
    NSArray *selectedCalendars = [EKCalendar selectedCalendarForEntityType:EKEntityTypeEvent];
    if (selectedCalendars.count) {
        NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:selectedCalendars];
        NSArray *events = [eventStore eventsMatchingPredicate:predicate];
        [todoEvents addObjectsFromArray:[self todosEventsFromEvents:events withStartDate:startDate endDate:endDate]];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
        [todoEvents sortUsingDescriptors:@[sortDescriptor]];
    }
    return todoEvents;
}

+ (NSArray *)findAllIncompleteWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSArray *todoEvents = [self findAllWithStartDate:startDate endDate:endDate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed = %@", @NO];
    return [todoEvents filteredArrayUsingPredicate:predicate];
}

+ (NSArray *)todosEventsFromEvents:(NSArray *)events withStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSMutableArray *todoEvents = [NSMutableArray array];
    [events enumerateObjectsUsingBlock:^(EKEvent *event, NSUInteger idx, BOOL *stop) {
        NSInteger days = [event.startDate daysBeforeDate:event.endDate] + 1;
        for (int i = 0; i < days; i++) {
            NSDate *date = [event.startDate dateByAddingDays:i];
            if ([date isAfterDate:startDate] && [date isBeforeDate:endDate]) {
                
                NSPredicate *todoPredicate = [NSPredicate predicateWithFormat:@"eventIdentifier = %@ AND date = %@", event.eventIdentifier, date];
                Todo *todo = [Todo findFirstWithPredicate:todoPredicate];
                
                if (!todo) {
                    todo = [Todo createEntity];
                    todo.eventIdentifier = event.eventIdentifier;
                    todo.date = date;
                    todo.position = @-1;
                    
                    NSDate *eventModifiedDate = [event.lastModifiedDate morning];
                    NSDate *calendarEnabledDate = [[event.calendar.enabledDate yesterday] morning];
                    if ([date isAfterDate:calendarEnabledDate] || [eventModifiedDate isAfterDate:calendarEnabledDate]) {
                        todo.completed = @NO;
                    } else {
                        todo.completed = @YES;
                    }
                }
                
                TodoEvent *todoEvent = [[TodoEvent alloc] initWithEvent:event todo:todo];
                [todoEvents addObject:todoEvent];
            }
        }
    }];
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
    return todoEvents;
    
}

+ (NSArray *)todoEventsFromEvent:(EKEvent *)event
{
    EKCalendar *calendar = event.calendar;
    NSMutableArray *todoEvents = [[NSMutableArray alloc] init];
    
    NSInteger days = [event.startDate daysBeforeDate:event.endDate] + 1;
    for (int i = 0; i < days; i++) {
        NSString *eventIdentifier = event.eventIdentifier;
        NSDate *date = [event.startDate dateByAddingDays:i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventIdentifier = %@ AND date = %@", eventIdentifier, date];
        
        Todo *todo = [Todo findFirstWithPredicate:predicate];
        if (!todo) {
            todo = [Todo createEntity];
            todo.eventIdentifier = event.eventIdentifier;
            todo.date = date;
            todo.position = @-1;

            NSDate *eventModifiedDate = [event.lastModifiedDate morning];
            NSDate *calendarEnabledDate = [[calendar.enabledDate yesterday] morning];
            if ([date isAfterDate:calendarEnabledDate] || [eventModifiedDate isAfterDate:calendarEnabledDate]) {
                todo.completed = @NO;
            } else {
                todo.completed = @YES;
            }
            [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
        }
        
        TodoEvent *todoEvent = [[TodoEvent alloc] initWithEvent:event todo:todo];
        [todoEvents addObject:todoEvent];
    }
    return todoEvents;
}


#pragma mark - Notifications

- (NSArray *)localNotifications
{
    NSMutableArray *localNotifications = [NSMutableArray array];
    
    if (!self.allDay) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"%@, %@", self.title, self.relativeStartTime];
        localNotification.fireDate = self.startDate;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [localNotifications addObject:localNotification];
    }
    
    for (EKAlarm *alarm in self.event.alarms) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"%@, %@", self.title, self.relativeStartTime];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        if (alarm.absoluteDate) {
            localNotification.fireDate = alarm.absoluteDate;
        } else {
            localNotification.fireDate = [self.startDate dateByAddingTimeInterval:alarm.relativeOffset];
        }
        
        if (!self.allDay && [localNotification.fireDate isEqualToDate:self.startDate]) { continue; }
        
        [localNotifications addObject:localNotification];
    }
    return localNotifications;
}


#pragma mark - View helpers (move to view model)

// TODO: View model?

- (NSString *)humanReadableStartTime
{
    NSString *humanReadableTime = @"";
    if (!self.allDay) {
        humanReadableTime = [[NSDateFormatter timeFormatter] stringFromDate:self.startDate];
    }
    return humanReadableTime;
}

- (NSString *)humanReadableEndTime
{
    NSString *humanReadableTime = @"";
    if (!self.allDay) {
        humanReadableTime = [[NSDateFormatter timeFormatter] stringFromDate:self.endDate];
        humanReadableTime = [NSString stringWithFormat:@"Ends at %@", humanReadableTime];
    }
    return humanReadableTime;
}

#pragma mark - Private

- (NSString *)relativeStartTime
{
    NSString *date = [[NSDateFormatter relativeDateFormatter] stringFromDate:self.startDate];
    NSString *time = [[NSDateFormatter timeFormatter] stringFromDate:self.startDate];
    if (self.allDay) {
        return [NSString stringWithFormat:@"%@", date];
    } else {
        return [NSString stringWithFormat:@"%@ at %@", date, time];
    }
}

@end
