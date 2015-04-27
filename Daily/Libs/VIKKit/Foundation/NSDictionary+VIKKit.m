//
//  NSDictionary+VIKKit.m
//  Daily
//
//  Created by Viktor Fröberg on 27/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "NSDictionary+VIKKit.h"

@implementation NSDictionary (VIKKit)

- (NSDictionary *)dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *result = [self mutableCopy];
    [result addEntriesFromDictionary:dictionary];
    return result;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [NSMethodSignature signatureWithObjCTypes:"@@:"];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    id value = [self objectForKey:NSStringFromSelector([anInvocation selector])];
    [anInvocation setReturnValue:&value];
}

@end
