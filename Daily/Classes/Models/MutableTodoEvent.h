//
//  MutableTodoEvent.h
//  Daily
//
//  Created by Viktor Fröberg on 07/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Todo, EKEvent;

@interface MutableTodoEvent : NSObject

@property (nonatomic, strong) NSString *todoEventIdentifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSString *url;

@property (nonatomic) NSUInteger position;
@property (nonatomic) BOOL completed;
@property (nonatomic) BOOL allDay;

- (BOOL)isEqualToTodoEvent:(MutableTodoEvent *)todoEvent;

- (BOOL)hasFutureEvents;

+ (instancetype)todoEventFromTodo:(Todo *)todo event:(EKEvent *)event;

+ (NSString *)eventIdentifierFromTodoEventIdentifier:(NSString *)todoEventIdentifier;

+ (NSDate *)dateFromTodoEventIdentifier:(NSString *)todoEventIdentifier;

@end
