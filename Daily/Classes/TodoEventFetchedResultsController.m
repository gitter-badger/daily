//
//  TodoEventFetchedResultsController.m
//  Daily
//
//  Created by Viktor Fröberg on 10/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "EKEventStore+VFDaily.h"

#import "TodoEvent.h"

#import "TodoEventFetchedResultsController.h"

@interface TodoEventFetchedResultsController ()

@property (nonatomic, strong) NSArray *sections;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, getter=isFetching) BOOL fetching;

@end

@implementation TodoEventFetchedResultsController

- (instancetype)init
{
    return [self initWithStartDate:[NSDate date] endDate:[NSDate date]];
}

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    self = [super init];
    if (self) {
        self.startDate = startDate;
        self.endDate = endDate;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChanged:) name:EKEventStoreChangedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:[NSManagedObjectContext defaultContext]];
        
        [self performFetch];
    }
    return self;
}

- (TodoEvent *)objectAtIndexPath:(NSIndexPath *)indexPath
{
    TodoEventFetchedResultsSection *section = [self.sections objectAtIndex:indexPath.section];
    return [section.objects objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfSections
{
    return self.sections.count;
}

- (void)eventStoreChanged:(NSNotification *)notification
{
#warning FIXME: Running twice
    NSLog(@"eventStoreChanged:performFetch");
    [self performFetchAndBroadcastChanges];
}

- (void)managedObjectContextObjectsDidChange:(NSNotification *)notificaiton
{
#warning FIXME: Running four times
    [self performFetchAndBroadcastChanges];
}

- (NSArray *)fetch
{
    NSArray *events = [TodoEvent findAllWithStartDate:self.startDate endDate:self.endDate];
    
    NSPredicate *incompletedPredicate = [NSPredicate predicateWithFormat:@"completed = %@", @NO];
    NSArray *incompletedEvents = [events filteredArrayUsingPredicate:incompletedPredicate];
    
    NSPredicate *completedPredicate = [NSPredicate predicateWithFormat:@"completed = %@", @YES];
    NSArray *completedEvents = [[events filteredArrayUsingPredicate:completedPredicate] mutableCopy];
    
    TodoEventFetchedResultsSection *incompletedSection = [[TodoEventFetchedResultsSection alloc] initWithObjects:incompletedEvents];
    
    TodoEventFetchedResultsSection *completedSection = [[TodoEventFetchedResultsSection alloc] initWithObjects:completedEvents];
    
    return @[incompletedSection, completedSection];
}

- (void)performFetch
{
    [[EKEventStore sharedEventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.sections = [self fetch];
            });
        }
    }];
}

- (void)performFetchAndBroadcastChanges
{
    [[EKEventStore sharedEventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSArray *oldSections = [self.sections copy];
                NSArray *newSections = [self fetch];
                self.sections = newSections;
                
                [self.delegate todoEventControllerWillChangeContent:self];
                    
                NSArray *oldObjects = [oldSections valueForKeyPath:@"@unionOfArrays.objects"];
                NSArray *newObjects = [newSections valueForKeyPath:@"@unionOfArrays.objects"];
                
                [oldSections enumerateObjectsUsingBlock:^(TodoEventFetchedResultsSection *section, NSUInteger sectionIndex, BOOL *stop) {
                    
                    [section.objects enumerateObjectsUsingBlock:^(TodoEvent *todoEvent, NSUInteger objectIndex, BOOL *stop) {
                        
                        if (![newObjects containsObject:todoEvent]) {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:objectIndex inSection:sectionIndex];
                            [self.delegate todoEventController:self didChangeObject:todoEvent atIndexPath:indexPath forChangeType:TodoEventFetchedResultsChangeDelete newIndexPath:nil];
                        }
                        
                    }];
                    
                }];
                
                
                [newSections enumerateObjectsUsingBlock:^(TodoEventFetchedResultsSection *section, NSUInteger sectionIndex, BOOL *stop) {
                    
                    [section.objects enumerateObjectsUsingBlock:^(TodoEvent *todoEvent, NSUInteger objectIndex, BOOL *stop) {
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:objectIndex inSection:sectionIndex];
                        
                        if ([oldObjects containsObject:todoEvent]) {
                            
                            __block NSIndexPath *oldIndexPath;
                            [oldSections enumerateObjectsUsingBlock:^(TodoEventFetchedResultsSection *oldSection, NSUInteger oldSectionIndex, BOOL *stop) {
                                
                                if ([oldSection.objects containsObject:todoEvent]) {
                                    NSInteger oldObjectIndex = [oldSection.objects indexOfObject:todoEvent];
                                    oldIndexPath = [NSIndexPath indexPathForRow:oldObjectIndex inSection:oldSectionIndex];
                                }
                                
                            }];
                            
                            if (![oldIndexPath isEqual:indexPath]) {
                                [self.delegate todoEventController:self didChangeObject:todoEvent atIndexPath:oldIndexPath forChangeType:TodoEventFetchedResultsChangeMove newIndexPath:indexPath];
                            }
                            //                            [self.delegate todoEventController:self didChangeObject:todoEvent atIndexPath:indexPath forChangeType:TodoEventFetchedResultsChangeUpdate newIndexPath:nil];
                        } else {
                            [self.delegate todoEventController:self didChangeObject:todoEvent atIndexPath:nil forChangeType:TodoEventFetchedResultsChangeInsert newIndexPath:indexPath];
                        }
                        
                    }];
                    
                }];
                
                [self.delegate todoEventControllerDidChangeContent:self];
                
                self.fetching = NO;
            });
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EKEventStoreChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:[NSManagedObjectContext defaultContext]];
}

@end


@interface TodoEventFetchedResultsSection ()

@property (nonatomic, strong) NSArray *objects;

@end

@implementation TodoEventFetchedResultsSection

- (instancetype)initWithObjects:(NSArray *)objects
{
    self = [super init];
    if (self) {
        self.objects = objects;
    }
    return self;
}

- (NSInteger)numberOfObjects
{
    return self.objects.count;
}

@end
