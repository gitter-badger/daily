//
//  NSManagedObject+VIKKit.m
//  Daily
//
//  Created by Viktor Fröberg on 09/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "NSManagedObject+VIKKit.h"

@implementation NSManagedObject (VIKKit)

+ (id)findOrCreateByAttribute:(NSString *)attribute withValue:(id)value
{
    return [self findOrCreateByAttribute:attribute
                                      withValue:value
                                  inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id)findOrCreateByAttribute:(NSString *)attribute withValue:(id)value inContext:(NSManagedObjectContext *)context
{
    id object = [self MR_findFirstByAttribute:attribute withValue:value];
    
    if (nil == object)
    {
        object = [self MR_createInContext:context];
        [object setValue:value forKey:attribute];
    }
    
    return object;
}

@end
