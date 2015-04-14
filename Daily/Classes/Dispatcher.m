//
//  Dispatcher.m
//  Daily
//
//  Created by Viktor Fröberg on 27/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "Dispatcher.h"

@implementation Dispatcher

+ (id)sharedDispatcher {
    static Dispatcher *sharedDispatcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDispatcher = [[self alloc] init];
    });
    return sharedDispatcher;
}

@end
