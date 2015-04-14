//
//  NSArray+VIKKit.h
//  Daily
//
//  Created by Viktor Fröberg on 09/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef id (^VKEnumerationBlock)(id object);
typedef BOOL (^VKSelectionBlock)(id object);

@interface NSArray (VIKKit)

- (NSArray *)mappedArrayWithBlock:(VKEnumerationBlock)enumerationBlock;
- (NSArray *)arrayBySelectingObjectsWithBlock:(VKSelectionBlock)selectionBlock;
- (NSArray *)arrayByRejectingObjectsWithBlock:(VKSelectionBlock)selectionBlock;

@end
