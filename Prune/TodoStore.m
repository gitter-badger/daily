//
//  CompletionStore.m
//  Prune
//
//  Created by Viktor Fröberg on 21/08/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "TodoStore.h"
#import "PersistentStack.h"

@interface TodoStore ()

@property (nonatomic, strong) PersistentStack *persistentStack;

@end

@implementation TodoStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.persistentStack = [[PersistentStack alloc] initWithStoreURL:self.storeURL modelURL:self.modelURL];
    }
    
    return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.persistentStack.managedObjectContext;
}

- (void)save
{
    NSError *error;
    [[self managedObjectContext] save:&error];
    if (error) {
        NSLog(@"error: %@", error);
    }
}

- (NSURL*)storeURL
{
    NSURL* documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    return [documentsDirectory URLByAppendingPathComponent:@"db.sqlite"];
}

- (NSURL*)modelURL
{
    return [[NSBundle mainBundle] URLForResource:@"store" withExtension:@"momd"];
}

@end
