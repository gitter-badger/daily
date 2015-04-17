//
//  MutableTodoEvent.h
//  Daily
//
//  Created by Viktor Fröberg on 07/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Todo, EKEvent;

@interface TodoEvent : NSObject

@property (nonatomic, copy) NSString *todoEventIdentifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, assign) NSUInteger position;

@property (nonatomic, assign) BOOL completed;
@property (nonatomic, assign) BOOL allDay;


+ (instancetype)todoEventFromTodo:(Todo *)todo event:(EKEvent *)event;

+ (NSString *)eventIdentifierFromTodoEventIdentifier:(NSString *)todoEventIdentifier;

+ (NSDate *)dateFromTodoEventIdentifier:(NSString *)todoEventIdentifier;


- (BOOL)isEqualToTodoEvent:(TodoEvent *)todoEvent;

- (BOOL)hasFutureEvents;

@end
