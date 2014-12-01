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

@interface TodoEvent()

@property (nonatomic, strong) EKEvent *event;
@property (nonatomic, strong) Todo *todo;

@end

@implementation TodoEvent

- (instancetype)initWithEvent:(EKEvent *)event todo:(Todo *)todo
{
    self = [super init];

    if (self) {
        self.event = event;
        self.todo = todo;
    }
    
    return self;
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

- (NSString *)location
{
    return self.event.location;
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
}

- (BOOL)isCompleted
{
    return self.completed.boolValue;
}

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

- (NSString *)title
{
    return self.event.title;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ pos:%@ done:%@", self.title, self.position, self.completed];
}

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

@end
