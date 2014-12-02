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
    [self synchronize];
}

- (NSDate *)created
{
    return [self valueForKey:@"kUserCreated"];
}

- (void)setCreated:(NSDate *)date
{
    [self setObject:date forKey:@"kUserCreated"];
    [self synchronize];
}

- (NSDate *)lastSeen
{
    return [self valueForKey:@"kUserLastSeen"];
}

- (void)setLastSeen:(NSDate *)date
{
    [self setObject:date forKey:@"kUserLastSeen"];
    [self synchronize];
}

@end
