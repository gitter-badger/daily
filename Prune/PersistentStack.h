//
//  PersistentStack.h
//  Daily
//
//  Created by Viktor Fröberg on 03/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PersistentStack : NSObject

- (id)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL;

@property (nonatomic,strong,readonly) NSManagedObjectContext* managedObjectContext;

@end
