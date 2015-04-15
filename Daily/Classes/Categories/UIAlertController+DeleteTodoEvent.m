//
//  VIKDeleteEventAlertController.m
//  Daily
//
//  Created by Viktor Fröberg on 12/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "UIAlertController+DeleteTodoEvent.h"
#import "TodoEvent.h"

@implementation UIAlertController (DeleteTodoEventFactory)

#pragma mark - Public

+ (UIAlertController *)alertControllerWithTodoEvent:(TodoEvent *)todoEvent handler:(DeleteTodoEventBlock)handler
{
    if ([todoEvent hasFutureEvents])
        return [self deleteRecurringTodoEventAlertControllerWithHandler:handler];
    
    return [self deleteSingleTodoEventAlertControllerWithHandler:handler];
}

#pragma mark - UIAlertController

+ (UIAlertController *)deleteRecurringTodoEventAlertControllerWithHandler:(DeleteTodoEventBlock)handler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"This is a repeating event." preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[self deleteThisTodoEventActionWithHandler:handler]];
    [alertController addAction:[self deleteFutureTodoEventActionWithHandler:handler]];
    [alertController addAction:[self cancelAlertAction]];
    
    return alertController;
}

+ (UIAlertController *)deleteSingleTodoEventAlertControllerWithHandler:(DeleteTodoEventBlock)handler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[self deleteSingleTodoEventActionWithHandler:handler]];
    [alertController addAction:[self cancelAlertAction]];
    
    return alertController;
}

+ (UIAlertController *)readOnlyWarningAlertController
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Can't delete event" message:@"Calendar is read only" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[self OKAlertAction]];
    
    return alertController;
}

#pragma mark - UIAlertAction

+ (UIAlertAction *)deleteSingleTodoEventActionWithHandler:(DeleteTodoEventBlock)handler
{
    return [UIAlertAction actionWithTitle:@"Delete Event" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        handler(TodoEventSpanThis);
    }];
}

+ (UIAlertAction *)deleteThisTodoEventActionWithHandler:(DeleteTodoEventBlock)handler
{
    return [UIAlertAction actionWithTitle:@"Delete This Event Only" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        handler(TodoEventSpanThis);
    }];
}

+ (UIAlertAction *)deleteFutureTodoEventActionWithHandler:(DeleteTodoEventBlock)handler
{
    return [UIAlertAction actionWithTitle:@"Delete All Future Events" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        handler(TodoEventSpanFuture);
    }];
}

+ (UIAlertAction *)cancelAlertAction
{
    return [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
}

+ (UIAlertAction *)OKAlertAction
{
    return [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
}

@end
