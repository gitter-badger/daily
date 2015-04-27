//
//  NSNumber+VIKKit.m
//  Daily
//
//  Created by Viktor Fröberg on 22/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "NSNumber+VIKKit.h"

@implementation NSNumber (VIKKit)

- (NSArray *)arrayByMapping:(id (^)(id))block
{
    NSInteger length = self.integerValue;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:length];
    for (int i = 0; i < length; i++) {
        [array addObject:block(@(i))];
    }
    return array;
}

@end
