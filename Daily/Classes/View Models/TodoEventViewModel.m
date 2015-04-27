//
//  TodoEventViewModel.m
//  Daily
//
//  Created by Viktor Fröberg on 16/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "TodoEventViewModel.h"
#import "TodoEvent.h"

@interface TodoEventViewModel ()

@end

@implementation TodoEventViewModel

+ (NSDateFormatter *)timeFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"jj:mm" options:0 locale:[NSLocale currentLocale]];
    });
    return formatter;
}

+ (NSDateFormatter *)fullDateFormatter
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterFullStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
    });
    return formatter;
}

+ (NSCalendar *)calendar
{
    static NSCalendar *calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    return calendar;
}

- (instancetype)initWithTodoEvent:(TodoEvent *)todoEvent
{
    self = [super init];
    if (self) {
        _titleText = todoEvent.title.length ? todoEvent.title : @"";
        _locationText = todoEvent.location.length ? todoEvent.location : @"";
        _notesText = todoEvent.notes.length ? todoEvent.notes : @"";
        _urlText = todoEvent.url ? todoEvent.url : @"";
        _completed = todoEvent.completed;
        _timeText = [self startEndTimeTextFrom:todoEvent];
        _dateTextFull = [self dateTextFullFromTodoEvent:todoEvent];
        _dateText = [self dateTextFromTodoEvent:todoEvent];
    }
    return self;
}

- (NSString *)dateTextFromTodoEvent:(TodoEvent *)todoEvent
{
    NSString *startDate = [[TodoEventViewModel fullDateFormatter] stringFromDate:todoEvent.startDate];
    NSString *endDate = [[TodoEventViewModel fullDateFormatter] stringFromDate:todoEvent.endDate];
    
    if ([[TodoEventViewModel calendar] isDate:todoEvent.startDate inSameDayAsDate:todoEvent.endDate]) {
        return [NSString stringWithFormat:@"%@", startDate];
    } else {
        return [NSString stringWithFormat:@"%@ - %@", startDate, endDate];
    }
}

- (NSString *)dateTextFullFromTodoEvent:(TodoEvent *)todoEvent
{   
    NSString *startDate = [[TodoEventViewModel fullDateFormatter] stringFromDate:todoEvent.startDate];
    NSString *endDate = [[TodoEventViewModel fullDateFormatter] stringFromDate:todoEvent.endDate];
    
    NSString *startTime = [self startTimeTextFromTodoEvent:todoEvent];
    NSString *endTime = [self endTimeTextFromTodoEvent:todoEvent];
    
    if (todoEvent.allDay) {
        if ([[TodoEventViewModel calendar] isDate:todoEvent.startDate inSameDayAsDate:todoEvent.endDate]) {
            return [NSString stringWithFormat:@"%@", startDate];
        } else {
            return [NSString stringWithFormat:@"%@ - %@", startDate, endDate];
        }
    }
    else {
        if ([[TodoEventViewModel calendar] isDate:todoEvent.startDate inSameDayAsDate:todoEvent.endDate]) {
            return [NSString stringWithFormat:@"%@\n%@ - %@", startDate, startTime, endTime];
        } else {
            return [NSString stringWithFormat:@"%@ at %@ - %@ at %@", startDate, startTime, endDate, endTime];
        }
    }
}

- (NSString *)startTimeTextFromTodoEvent:(TodoEvent *)todoEvent
{
    if (todoEvent.allDay)
        return @"";
    
    return [[TodoEventViewModel timeFormatter] stringFromDate:todoEvent.startDate];
}

- (NSString *)endTimeTextFromTodoEvent:(TodoEvent *)todoEvent
{
    if (todoEvent.allDay)
        return @"";
    
    return [[TodoEventViewModel timeFormatter] stringFromDate:todoEvent.endDate];
}

- (NSString *)startEndTimeTextFrom:(TodoEvent *)todoEvent
{
    if (todoEvent.allDay)
        return @"";
    
    if ([[TodoEventViewModel calendar] isDate:todoEvent.startDate inSameDayAsDate:todoEvent.date]) {
        return [self startTimeTextFromTodoEvent:todoEvent];
    }
    else if ([[TodoEventViewModel calendar] isDate:todoEvent.endDate inSameDayAsDate:todoEvent.date]) {
        return [NSString stringWithFormat:@"Ends at %@", [self endTimeTextFromTodoEvent:todoEvent]];
    }
    else {
        return @"All day";
    }
}

@end
