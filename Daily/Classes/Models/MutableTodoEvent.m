//
//  DAYTodoEvent.m
//  Daily
//
//  Created by Viktor Fröberg on 07/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "MutableTodoEvent.h"

@interface MutableTodoEvent ()

@end

@implementation MutableTodoEvent

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    return [self isEqualToTodoEvent:object];
}

- (BOOL)isEqualToTodoEvent:(MutableTodoEvent *)todoEvent
{
    return [todoEvent.identifier isEqual:self.identifier];
}

- (BOOL)hasFutureEvents
{
    // TODO: FIX THIS...
    return NO;
}

- (NSString *)description
{
    return self.title;
}

@end
