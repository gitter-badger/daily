//
//  NSArray+VIKKit.m
//  Daily
//
//  Created by Viktor Fröberg on 09/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "NSArray+VIKKit.h"

@implementation NSArray (VIKKit)

//- (id)find:(BOOL (^)(id))block
//{
//    NSParameterAssert(block != nil);
//    return [[self select:^BOOL(id obj) {
//        return block(obj);
//    }] firstObject];
//}
//
//- (NSArray *)select:(BOOL (^)(id obj))block
//{
//    NSParameterAssert(block != nil);
//    return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//        return block(obj);
//    }]];
//}
//
//- (NSArray *)reject:(BOOL (^)(id obj))block
//{
//    NSParameterAssert(block != nil);
//    return [self select:^BOOL(id obj) {
//        return !block(obj);
//    }];
//}
//
//- (NSArray *)map:(id (^)(id obj))block
//{
//    NSParameterAssert(block != nil);
//    
//    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
//    
//    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        id value = block(obj) ?: [NSNull null];
//        [result addObject:value];
//    }];
//    
//    return result;
//}
//
//- (id)reduce:(id)initial withBlock:(id (^)(id sum, id obj))block
//{
//    NSParameterAssert(block != nil);
//    
//    __block id result = initial;
//    
//    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        result = block(result, obj);
//    }];
//    
//    return result;
//}

@end
