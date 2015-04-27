//
//  TodoEvent.h
//  Daily
//
//  Created by Viktor Fröberg on 07/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Mantle.h"

@interface TodoEvent : MTLModel

@property (nonatomic, copy, readonly) NSString *todoEventIdentifier;
@property (nonatomic, copy, readonly) NSString *eventIdentifier;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSDate *date;
@property (nonatomic, assign, readonly) BOOL allDay;
@property (nonatomic, copy, readonly) NSDate *startDate;
@property (nonatomic, copy, readonly) NSDate *endDate;
@property (nonatomic, copy, readonly) NSString *location;
@property (nonatomic, copy, readonly) NSString *url;
@property (nonatomic, copy, readonly) NSString *notes;
@property (nonatomic, assign, readonly) NSUInteger position;
@property (nonatomic, assign, readonly) BOOL completed;

+ (NSDate *)dateFromTodoEventIdentifier:(NSString *)todoEventIdentifier;

- (BOOL)hasFutureEvents;
- (BOOL)isEqualToTodoEvent:(TodoEvent *)todoEvent;

@end
