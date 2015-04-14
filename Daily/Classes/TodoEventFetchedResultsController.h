//
//  TodoEventFetchedResultsController.h
//  Daily
//
//  Created by Viktor Fröberg on 10/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TodoEventFetchedResultsControllerDelegate;

@interface TodoEventFetchedResultsController : NSObject

@property (nonatomic, strong, readonly) NSArray *sections;

@property (nonatomic, weak) id delegate;

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

- (TodoEvent *)objectAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfSections;

@end

@protocol TodoEventFetchedResultsControllerDelegate

typedef NS_ENUM(NSUInteger, TodoEventFetchedResultsChangeType) {
    TodoEventFetchedResultsChangeInsert = 1,
    TodoEventFetchedResultsChangeDelete = 2,
    TodoEventFetchedResultsChangeMove = 3,
    TodoEventFetchedResultsChangeUpdate = 4
} NS_ENUM_AVAILABLE(NA,  3_0);

- (void)todoEventControllerWillChangeContent:(TodoEventFetchedResultsController *)controller;

- (void)todoEventController:(TodoEventFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(TodoEventFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath;

- (void)todoEventControllerDidChangeContent:(TodoEventFetchedResultsController *)controller;

@end

@interface TodoEventFetchedResultsSection : NSObject

@property (nonatomic, strong, readonly) NSArray *objects;

- (instancetype)initWithObjects:(NSArray *)objects;

- (NSInteger)numberOfObjects;

@end
