//
//  NSArray+VIKKit.h
//  Daily
//
//  Created by Viktor Fröberg on 09/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (VIKKit)

- (id)firstBySelecting:(BOOL (^)(id obj))block;

- (NSArray *)arrayBySelecting:(BOOL (^)(id obj))block;

- (NSArray *)arrayByRejecting:(BOOL (^)(id obj))block;

- (NSArray *)flatArrayByMapping:(id (^)(id obj))block;

- (NSArray *)arrayByMapping:(id (^)(id obj))block;

- (NSArray *)arrayByMappingIndexed:(id (^)(id obj, NSUInteger idx))block;

- (NSArray *)arrayByMovingObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

- (NSArray *)arrayByReplacingObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

- (NSArray *)arraySortedByKeys:(NSArray *)keys ascending:(BOOL)ascending;

@end
