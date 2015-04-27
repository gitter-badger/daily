//
//  MTLModel+VIKKit.m
//  Daily
//
//  Created by Viktor Fröberg on 27/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "MTLModel+VIKKit.h"

@implementation MTLModel (VIKKit)

- (instancetype)modelByAddingEntriesFromDictionary:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)error
{
    NSDictionary *newDictionary = [self.dictionaryValue dictionaryByAddingEntriesFromDictionary:dictionary];
    return [[self class] modelWithDictionary:newDictionary error:error];
}

@end
