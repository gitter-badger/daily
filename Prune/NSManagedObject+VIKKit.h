//
//  NSManagedObject+VIKKit.h
//  Daily
//
//  Created by Viktor Fröberg on 09/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (VIKKit)

+ (id)findOrCreateByAttribute:(NSString *)attribute withValue:(id)value;
+ (id)findOrCreateByAttribute:(NSString *)attribute withValue:(id)value inContext:(NSManagedObjectContext *)context;

@end
