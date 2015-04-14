//
//  NSString+VIKKit.m
//  Daily
//
//  Created by Viktor Fröberg on 09/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "NSString+VIKKit.h"

@implementation NSString (VIKKit)

- (BOOL)containsString:(NSString *)string
{
    if ([self rangeOfString:string].location == NSNotFound)
        return NO;
    
    return YES;
}

- (BOOL)containsStrings:(NSArray *)strings
{
    __block BOOL containsStrings = YES;
    
    [strings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *string = obj;
        
        if (![self containsString:string])
        {
            containsStrings = NO;
            *stop = YES;
        }
    }];
    
    return containsStrings;
}

@end
