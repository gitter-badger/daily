//
//  Todo+VFDaily.h
//  Daily
//
//  Created by Viktor Fröberg on 05/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "Todo.h"

@interface Todo (VFDaily)

+ (void)migrateFromTodoIdentifiers;
+ (void)migrateFromTimeToNoneTime;

@end