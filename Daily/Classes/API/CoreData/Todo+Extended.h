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

+ (instancetype)todoFromEvent:(EKEvent *)event forDate:(NSDate *)date inContext:(NSManagedObjectContext *)context;
+ (NSString *)todoIdentifierFromEventIdentifier:(NSString *)eventIdentifier date:(NSDate *)date;

@end
