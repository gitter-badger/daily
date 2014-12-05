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

@interface TodoEvent()

@property (nonatomic, strong) EKEvent *event;
@property (nonatomic, strong) Todo *todo;

- (instancetype)initWithEvent:(EKEvent *)event todo:(Todo *)todo;

@end

@implementation TodoEvent

@dynamic startDate, endDate, calendar, location, title, recurrenceRules;

- (instancetype)initWithEvent:(EKEvent *)event todo:(Todo *)todo
{
    self = [super init];

    if (self) {
        self.event = event;
        self.todo = todo;
    }
    
    return self;
}

#pragma mark - Event delegation

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

- (BOOL)allDay
{
    return self.event.allDay;
}

- (BOOL)allowsContentModifications
{
    return self.event.calendar.allowsContentModifications;
}

- (NSString *)location
{
    return self.event.location;
}

- (BOOL)deleteThisTodoEvent
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

- (BOOL)deleteFutureTodoEvents
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

#pragma mark - Todo delegation

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
}

- (BOOL)isCompleted
{
    return self.completed.boolValue;
}

+ (NSArray *)findAllWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    EKEventStore *eventStore = [EKEventStore sharedEventStore];
    NSMutableArray *todoEvents = [[NSMutableArray alloc] init];
    NSArray *selectedCalendars = [EKCalendar selectedCalendarForEntityType:EKEntityTypeEvent];
    if (selectedCalendars.count) {
        NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:selectedCalendars];
        NSArray *events = [eventStore eventsMatchingPredicate:predicate];
        [events enumerateObjectsUsingBlock:^(EKEvent *event, NSUInteger idx, BOOL *stop) {
            [todoEvents addObjectsFromArray:[self todoEventsFromEvent:event]];
        }];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
        [todoEvents sortUsingDescriptors:@[sortDescriptor]];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return todoEvents;
}

+ (NSArray *)findAllIncompleteWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSArray *todoEvents = [self findAllWithStartDate:startDate endDate:endDate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed = %@", @NO];
    return [todoEvents filteredArrayUsingPredicate:predicate];
}

+ (NSArray *)todoEventsFromEvent:(EKEvent *)event
{
    NSMutableArray *todoEvents = [[NSMutableArray alloc] init];
    
    NSInteger days = [event.startDate daysBeforeDate:event.endDate] + 1;
    for (int i = 0; i < days; i++) {
        NSDate *date = [event.startDate dateByAddingDays:i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventIdentifier = %@ AND date = %@", event.eventIdentifier, date];
        NSArray *todos = [Todo MR_findAllWithPredicate:predicate];
        
        Todo *todo = [todos lastObject];
        if (!todo) {
            todo = [Todo MR_createEntity];
            todo.eventIdentifier = event.eventIdentifier;
            todo.date = date;
            todo.position = @-1;
            
            NSDate *oneDayBeforeCalendarWasEnabled = [[event.calendar.enabledDate dateBySubtractingDays:1] dateAtEndOfDay];
            BOOL eventWasCreatedAfterCalendarWasEnabled = [oneDayBeforeCalendarWasEnabled isEarlierThanDate:date];
            if (eventWasCreatedAfterCalendarWasEnabled) {
                todo.completed = @NO;
            } else {
                todo.completed = @YES;
            }
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
    
    UILocalNotification *localNotification;
    
    if (!self.allDay) {
        localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"%@, %@", self.title, self.relativeStartTime];
        localNotification.fireDate = self.startDate;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [localNotifications addObject:localNotification];
    }
    
    for (EKAlarm *alarm in self.event.alarms) {
        localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"%@, %@", self.title, self.relativeStartTime];
        if (alarm.absoluteDate) {
            localNotification.fireDate = alarm.absoluteDate;
        } else {
            localNotification.fireDate = [self.startDate dateByAddingTimeInterval:alarm.relativeOffset];
        }
        
        if ([localNotification.fireDate isEqualToDate:self.startDate]) { continue; }
        
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [localNotifications addObject:localNotification];
    }
    return localNotifications;
}


#pragma mark - View helpers (move to view model)

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
