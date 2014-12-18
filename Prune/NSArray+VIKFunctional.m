//
//  NSArray+VIKKit.m
//  Daily
//
//  Created by Viktor Fröberg on 09/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "NSArray+VIKFunctional.h"

@implementation NSArray (VIKKit)

- (NSArray *)mappedArrayWithBlock:(VKEnumerationBlock)enumerationBlock
{
    NSMutableArray *returnArray = [NSMutableArray array];
    
    for (id object in self) {
        id returnObject = enumerationBlock(object);
        
        if (returnObject) [returnArray addObject:returnObject];
    }
    
    return [NSArray arrayWithArray:returnArray];
}

- (NSArray *)arrayBySelectingObjectsWithBlock:(VKSelectionBlock)selectionBlock
{
    return [self filteredArrayWithComparisonBlock:selectionBlock shouldSelect:YES];
}

- (NSArray *)arrayByRejectingObjectsWithBlock:(VKSelectionBlock)selectionBlock
{
    return [self filteredArrayWithComparisonBlock:selectionBlock shouldSelect:NO];
}

#pragma mark - Private

- (NSArray *)filteredArrayWithComparisonBlock:(VKSelectionBlock)comparisonBlock shouldSelect:(BOOL)shouldSelect
{
    NSMutableArray *returnArray = [NSMutableArray array];
    
    for (id object in self) {
        if (comparisonBlock(object) && shouldSelect) [returnArray addObject:object];
        else if (!comparisonBlock(object) && !shouldSelect) [returnArray addObject:object];
    }
    
    return [NSArray arrayWithArray:returnArray];
}

@end
