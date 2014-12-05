//
//  EKEventStore+VFDaily.m
//  Daily
//
//  Created by Viktor Fröberg on 05/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "EKEventStore+VFDaily.h"

@implementation EKEventStore (VFDaily)

+ (instancetype)sharedEventStore
{
    static EKEventStore *sharedEventStore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEventStore = [[EKEventStore alloc] init];
    });
    return sharedEventStore;
}

@end
