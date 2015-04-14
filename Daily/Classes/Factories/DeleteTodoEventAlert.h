//
//  VIKDeleteEventAlertController.h
//  Daily
//
//  Created by Viktor Fröberg on 12/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TodoEvent;

@protocol DeleteTodoEventAlertDelegate <NSObject>

@optional

- (void)deleteTodoEventAlertThis:(TodoEvent *)todoEvent;
- (void)deleteTodoEventAlertFuture:(TodoEvent *)todoEvent;

@end

@interface DeleteTodoEventAlert : NSObject

@property (nonatomic, strong, readonly) UIAlertController *alertController;
@property (nonatomic, weak) id <DeleteTodoEventAlertDelegate> delegate;

- (instancetype)initWithTodoEvent:(TodoEvent *)todoEvent;

@end
