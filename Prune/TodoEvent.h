//
//  TodoEvent.h
//  Daily
//
//  Created by Viktor Fröberg on 03/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKEvent, Todo;

@interface TodoEvent : NSObject

@property (nonatomic, strong, readonly) EKEvent *event;
@property (nonatomic, strong, readonly) Todo *todo;

- (instancetype)initWithEvent:(EKEvent *)event todo:(Todo *)todo;

- (NSDate *)startDate;
- (NSDate *)endDate;
- (NSString *)location;
- (BOOL)allDay;

- (NSNumber *)position;
- (void)setPosition:(NSNumber *)position;

- (NSNumber *)completed;
- (void)setCompleted:(NSNumber *)completed;
- (BOOL)isCompleted;

- (NSString *)humanReadableStartTime;
- (NSString *)humanReadableEndTime;
- (NSString *)title;

- (NSArray *)localNotifications;

@end
