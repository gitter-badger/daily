//
//  TodoEventStore.m
//  Daily
//
//  Created by Viktor Fröberg on 25/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "TodoEventStore.h"
#import "Dispatcher.h"

@interface TodoEventStore ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) id dispatchToken;

@property (nonatomic, strong) NSArray *todoEvents;

@end

@implementation TodoEventStore

+ (id)sharedStore {
    static TodoEventStore *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] init];
    });
    return sharedStore;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.todoEvents = @[];
        self.dispatchToken = [[Dispatcher sharedDispatcher] registerCallback:^(NSDictionary *payload) {
            
            NSString *actionType = [payload valueForKey:@"actionType"];
            
            if ([actionType isEqual:@"LOAD_TODOEVENTS_SUCCESS"]) {
                self.todoEvents = [payload valueForKey:@"todoEvents"];
            }

        }];
    }
    return self;
}

- (void)setTodoEvents:(NSArray *)todoEvents
{
    _todoEvents = todoEvents;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TodoEventStoreDidChangeNotification" object:self];
}

- (void)dealloc
{
    [[Dispatcher sharedDispatcher] unregisterCallback:self.dispatchToken];
}

#pragma mark - Helpers

@end
