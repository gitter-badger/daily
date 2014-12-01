//
//  CompletionStore.h
//  Prune
//
//  Created by Viktor Fröberg on 21/08/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TodoStore : NSObject

- (NSManagedObjectContext *)managedObjectContext;

- (void)save;

@end
