//
//  TodoEventStore.h
//  Daily
//
//  Created by Viktor Fröberg on 25/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TodoEventStore : NSObject

@property (nonatomic, strong, readonly) NSArray *todoEvents;

+ (instancetype)sharedStore;

@end
