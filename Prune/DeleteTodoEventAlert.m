//
//  VIKDeleteEventAlertController.m
//  Daily
//
//  Created by Viktor Fröberg on 12/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "DeleteTodoEventAlert.h"

#import "TodoEvent.h"

@interface DeleteTodoEventAlert ()

@property (nonatomic, strong) TodoEvent *todoEvent;
@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation DeleteTodoEventAlert

#pragma mark - NSObject

- (instancetype)initWithTodoEvent:(TodoEvent *)todoEvent
{
    self = [super init];
    if (self) {
        self.todoEvent = todoEvent;
    }
    return self;
}

#pragma mark - Public

- (UIAlertController *)alertController
{
    if ([self.todoEvent hasFutureEvents]) {
        return [self deleteRecurringTodoEventAlertController];
    } else {
        return [self deleteSingleTodoEventAlertController];
    }
}

#pragma mark - UIAlertController

- (UIAlertController *)deleteRecurringTodoEventAlertController
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"This is a repeating event." preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[self deleteThisTodoEventAction]];
    [alertController addAction:[self deleteFutureTodoEventAction]];
    [alertController addAction:[self cancelAlertAction]];
    
    return alertController;
}

- (UIAlertController *)deleteSingleTodoEventAlertController
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[self deleteSingleTodoEventAction]];
    [alertController addAction:[self cancelAlertAction]];
    
    return alertController;
}

#pragma mark - UIAlertAction

- (UIAlertAction *)deleteSingleTodoEventAction
{
    return [UIAlertAction actionWithTitle:@"Delete Event" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([self.delegate respondsToSelector:@selector(deleteTodoEventAlertThis:)]) {
            [self.delegate deleteTodoEventAlertThis:self.todoEvent];
        }
    }];
}

- (UIAlertAction *)deleteThisTodoEventAction
{
    return [UIAlertAction actionWithTitle:@"Delete This Event Only" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([self.delegate respondsToSelector:@selector(deleteTodoEventAlertThis:)]) {
            [self.delegate deleteTodoEventAlertThis:self.todoEvent];
        }
    }];
}

- (UIAlertAction *)deleteFutureTodoEventAction
{
    return [UIAlertAction actionWithTitle:@"Delete All Future Events" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([self.delegate respondsToSelector:@selector(deleteTodoEventAlertFuture:)]) {
            [self.delegate deleteTodoEventAlertFuture:self.todoEvent];
        }
    }];
}

- (UIAlertAction *)cancelAlertAction
{
    return [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
}

@end
