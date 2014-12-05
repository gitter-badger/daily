//
//  NSUserDefaults+DLY.m
//  Daily
//
//  Created by Viktor Fröberg on 01/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "NSUserDefaults+DLY.h"

@implementation NSUserDefaults (DLY)

- (NSString *)email
{
    return [self valueForKey:@"kUserEmail"];
}

- (void)setEmail:(NSString *)email
{
    [self setObject:email forKey:@"kUserEmail"];
}

- (BOOL)userHasOboarded
{
    if ([self created]) {
        return YES;
    }
    else if ([self valueForKey:@"kUserHasOnboarded"]) {
        NSNumber *userHasOboarded = [self valueForKey:@"kUserHasOnboarded"];
        return userHasOboarded.boolValue;
    }
    return NO;
}

- (NSDate *)created
{
    return [self valueForKey:@"kUserCreated"];
}

- (void)setCreated:(NSDate *)date
{
    [self setObject:date forKey:@"kUserCreated"];
}

- (NSDate *)lastSeen
{
    return [self valueForKey:@"kUserLastSeen"];
}

- (void)setLastSeen:(NSDate *)date
{
    [self setObject:date forKey:@"kUserLastSeen"];
}

@end
