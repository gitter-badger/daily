//
//  VIKDeleteEventAlertController.h
//  Daily
//
//  Created by Viktor Fröberg on 12/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MutableTodoEvent;

typedef NS_ENUM(NSUInteger, TodoEventSpan) {
    TodoEventSpanThis,
    TodoEventSpanFuture,
};

typedef void (^DeleteTodoEventBlock)(TodoEventSpan span);

@interface UIAlertController (DeleteTodoEventFactory)

+ (UIAlertController *)alertControllerWithTodoEvent:(MutableTodoEvent *)todoEvent handler:(DeleteTodoEventBlock)handler;

@end
