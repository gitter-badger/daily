//
//  Todo+Extended.m
//  Daily
//
//  Created by Viktor Fröberg on 03/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "NSManagedObject+Extended.h"

@implementation NSManagedObject (Extended)

+ (NSString *)entityName
{
    return NSStringFromClass([self class]);
}

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                         inManagedObjectContext:context];
}

@end
