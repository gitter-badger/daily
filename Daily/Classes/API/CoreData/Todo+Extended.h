//
//  Todo+Extended.h
//  Daily
//
//  Created by Viktor Fröberg on 27/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "Todo.h"

@class EKEvent;

@interface Todo (Extended)

+ (instancetype)findOrCreateWithEvent:(EKEvent *)event date:(NSDate *)date inContext:(NSManagedObjectContext *)context;

+ (instancetype)createTodoWithTodoIdentifier:(NSString *)todoIdentifier date:(NSDate *)date completed:(NSNumber *)completed inContext:(NSManagedObjectContext *)context;

+ (NSString *)todoIdentifierFromEventIdentifier:(NSString *)eventIdentifier date:(NSDate *)date;

@end
