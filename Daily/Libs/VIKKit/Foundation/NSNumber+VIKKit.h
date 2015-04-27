//
//  NSNumber+VIKKit.h
//  Daily
//
//  Created by Viktor Fröberg on 22/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (VIKKit)

- (NSArray *)arrayByMapping:(id (^)(id object))block;

@end
