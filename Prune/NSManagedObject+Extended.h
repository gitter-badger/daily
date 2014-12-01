//
//  Todo+Extended.h
//  Daily
//
//  Created by Viktor Fröberg on 03/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface NSManagedObject (Extended)

+ (NSString *)entityName;
+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;

@end
