//
//  VIKArrayResultsController.m
//  Daily
//
//  Created by Viktor Fröberg on 07/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "VIKArrayController.h"

@implementation VIKArrayController

@synthesize objects = _objects;

- (NSArray *)objects
{
    if (!_objects) {
        _objects = [NSArray array];
    }
    return _objects;
}

- (void)setObjects:(NSArray *)objects
{
    NSArray *oldObjects = [_objects copy];
    NSArray *newObjects = [objects copy];
    
    [self.delegate controllerWillChangeContent:self];
    
    _objects = objects;
    
    NSIndexSet *removedIndexes = [self removedIndexesFromArray:oldObjects toArray:newObjects];
    [removedIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        id object = [oldObjects objectAtIndex:index];
        [self.delegate controller:self didChangeObject:object atIndex:index forChangeType:VIKArrayChangeDelete newIndex:NSNotFound];
    }];
    
    NSIndexSet *addedIndexes = [self addedIndexesFromArray:oldObjects toArray:newObjects];
    [addedIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        id object = [newObjects objectAtIndex:index];
        [self.delegate controller:self didChangeObject:object atIndex:NSNotFound forChangeType:VIKArrayChangeInsert newIndex:index];
    }];
    
    NSArray *movedIndexes = [self movedIndexesFromArray:oldObjects toArray:newObjects];
    [movedIndexes enumerateObjectsUsingBlock:^(NSDictionary *fromToIndex, NSUInteger index, BOOL *stop) {
        NSNumber *fromIndex = [fromToIndex objectForKey:@"fromIndex"];
        NSNumber *toIndex = [fromToIndex objectForKey:@"toIndex"];
        
        id object = [oldObjects objectAtIndex:fromIndex.integerValue];
        [self.delegate controller:self didChangeObject:object atIndex:fromIndex.integerValue forChangeType:VIKArrayChangeMove newIndex:toIndex.integerValue];
    }];
    
    NSIndexSet *updatedIndexes = [self updatedIndexesFromArray:oldObjects toArray:newObjects];
    [updatedIndexes enumerateIndexesUsingBlock:^(NSUInteger toIndex, BOOL *stop) {
        id object = [newObjects objectAtIndex:toIndex];
        NSUInteger fromIndex = [oldObjects indexOfObject:object];
        [self.delegate controller:self didChangeObject:object atIndex:fromIndex forChangeType:VIKArrayChangeUpdate newIndex:toIndex];
    }];
    
    [self.delegate controllerDidChangeContent:self];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [self.objects objectAtIndex:index];
}

- (NSUInteger)numberOfObjects
{
    return self.objects.count;
}

- (NSIndexSet *)removedIndexesFromArray:(NSArray *)fromArray toArray:(NSArray *)toArray
{
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    
    for (int i = 0; i < fromArray.count; i++) {
        id object = [fromArray objectAtIndex:i];
        if (![toArray containsObject:object]) {
            [indexes addIndex:i];
        }
    }
    
    return [indexes copy];
}

- (NSIndexSet *)addedIndexesFromArray:(NSArray *)fromArray toArray:(NSArray *)toArray
{
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    
    for (int i = 0; i < toArray.count; i++) {
        id object = [toArray objectAtIndex:i];
        if (![fromArray containsObject:object]) {
            [indexes addIndex:i];
        }
    }
    
    return [indexes copy];
}

- (NSArray *)movedIndexesFromArray:(NSArray *)fromArray toArray:(NSArray *)toArray
{
    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    
    NSMutableArray *fromWithoutRemoved = [fromArray mutableCopy];
    [fromWithoutRemoved removeObjectsAtIndexes:[self removedIndexesFromArray:fromArray toArray:toArray]];
    
    NSMutableArray *toWithoutAdded = [toArray mutableCopy];
    [toWithoutAdded removeObjectsAtIndexes:[self addedIndexesFromArray:fromArray toArray:toArray]];
    
    for (int fromIndex = 0; fromIndex < fromWithoutRemoved.count; fromIndex++) {
        id object = [fromWithoutRemoved objectAtIndex:fromIndex];
        int toIndex = [toWithoutAdded indexOfObject:object];
        
        if (fromIndex != toIndex) {
            NSMutableDictionary *fromToindex = [[NSMutableDictionary alloc] init];
            [fromToindex setValue:[NSNumber numberWithInteger:[fromArray indexOfObject:object]] forKey:@"fromIndex"];
            [fromToindex setValue:[NSNumber numberWithInteger:[toArray indexOfObject:object]] forKey:@"toIndex"];
            [indexes addObject:[fromToindex copy]];
        }
    }
    
    return [indexes copy];
}

- (NSIndexSet *)updatedIndexesFromArray:(NSArray *)fromArray toArray:(NSArray *)toArray
{
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    
    for (int i = 0; i < toArray.count; i++) {
        id object = [toArray objectAtIndex:i];
        if ([fromArray containsObject:object]) {
            int fromIndex = [fromArray indexOfObject:object];
            id object2 = [fromArray objectAtIndex:fromIndex];
            if (object != object2) {
                [indexes addIndex:i];
            }
        }
    }
    
    return [indexes copy];
}

@end
