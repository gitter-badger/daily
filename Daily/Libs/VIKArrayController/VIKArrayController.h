//
//  VIKArrayResultsController.h
//  Daily
//
//  Created by Viktor Fröberg on 07/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VIKArrayControllerDelegate;

@interface VIKArrayController : NSObject

@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, assign) id <VIKArrayControllerDelegate> delegate;

@property (nonatomic, readonly) NSUInteger numberOfObjects;

- (id)objectAtIndex:(NSUInteger)index;

@end

@protocol VIKArrayControllerDelegate <NSObject>

typedef NS_ENUM(NSUInteger, VIKArrayChangeType) {
    VIKArrayChangeInsert = 1,
    VIKArrayChangeDelete = 2,
    VIKArrayChangeMove = 3,
    VIKArrayChangeUpdate = 4
};

@optional
- (void)controllerWillChangeContent:(VIKArrayController *)controller;

@optional
- (void)controller:(VIKArrayController *)controller didChangeObject:(id)anObject
       atIndex:(NSUInteger)index forChangeType:(VIKArrayChangeType)type
      newIndex:(NSUInteger)newIndex;

@optional
- (void)controllerDidChangeContent:(VIKArrayController *)controller;

@end
