//
//  Todo+VFDaily.m
//  Daily
//
//  Created by Viktor Fröberg on 05/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "Todo+VFDaily.h"
#import "NSDateFormatter+Extended.h"

@implementation Todo (VFDaily)

+ (void)migrateFromTodoIdentifiers
{
    NSArray *todos = [self findAll];
    for (Todo *todo in todos) {
        if (todo.todoIdentifier && todo.todoIdentifier.length) {
            NSString *dateString = [todo.todoIdentifier substringFromIndex:todo.todoIdentifier.length - 8];
            NSDate *date = [[NSDateFormatter compactFullDateFormat] dateFromString:dateString];
            NSString *eventIdentifier = [todo.todoIdentifier substringToIndex:todo.todoIdentifier.length - 8];
            todo.date = date;
            todo.eventIdentifier = eventIdentifier;
        }
    }
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

+ (void)migrateFromTimeToNoneTime
{
    NSArray *todos = [self findAll];
    [todos enumerateObjectsUsingBlock:^(Todo *todo, NSUInteger idx, BOOL *stop) {
        todo.date = [todo.date startOfDay];
    }];
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

@end
