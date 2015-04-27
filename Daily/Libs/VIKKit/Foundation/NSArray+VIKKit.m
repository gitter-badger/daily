//
//  NSArray+VIKKit.m
//  Daily
//
//  Created by Viktor Fröberg on 09/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "NSArray+VIKKit.h"

@implementation NSArray (VIKKit)

- (id)firstBySelecting:(BOOL (^)(id obj))block
{
    return [self find:block];
}

- (NSArray *)arrayBySelecting:(BOOL (^)(id obj))block
{
    return [self select:block];
}

- (NSArray *)arrayByRejecting:(BOOL (^)(id obj))block
{
    return [self reject:block];
}

- (NSArray *)flatArrayByMapping:(id (^)(id obj))block
{
    return [[self map:block] flatten];
}

- (NSArray *)arrayByMapping:(id (^)(id obj))block
{
    return [self map:block];
}

-(NSArray *)arrayByMappingIndexed:(id (^)(id obj, NSUInteger idx))block
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [array addObject:block(obj, idx) ?: [NSNull null]];
    }];
    
    return array;
}

- (NSArray *)arrayByMovingObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    NSMutableArray *result = [self mutableCopy];
    
    id object = [result objectAtIndex:fromIndex];
    [result removeObjectAtIndex:fromIndex];
    [result insertObject:object atIndex:toIndex];
    
    return result;
}

- (NSArray *)arrayByReplacingObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    NSMutableArray *result = [self mutableCopy];
    [result replaceObjectAtIndex:index withObject:anObject];
    return result;
}

- (NSArray *)arraySortedByKeys:(NSArray *)keys ascending:(BOOL)ascending
{
    NSArray *sortDescriptors = [keys arrayByMapping:^NSSortDescriptor *(NSString *key) {
        return [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
    }];
    return [self sortedArrayUsingDescriptors:sortDescriptors];
}

@end
