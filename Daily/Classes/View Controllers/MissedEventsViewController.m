//
//  MissedEventsViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 28/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

// Frameworks
#import <EventKitUI/EventKitUI.h>

// Categories
#import "EKEventStore+VFDaily.h"

// Classes?
#import "DeleteTodoEventAlert.h"
#import "TodoEventsCache.h"

// Models
#import "TodoEvent.h"

// Views
#import "VIKTodoEventCell.h"

// Controllers
#import "MissedEventsViewController.h"
#import "DetailViewController.h"

@interface MissedEventsViewController () <UITableViewDataSource,
                                          UITableViewDelegate,
                                          EKEventEditViewDelegate,
                                          VIKTodoEventCellDelegate,
                                          DeleteTodoEventAlertDelegate>

@property (nonatomic, strong) TodoEventsCache *todoEventsCache;

@end

@implementation MissedEventsViewController

#pragma mark - EXTRACT

- (UIAlertController *)readOnlyAlertController
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Can't edit event" message:@"Calendar is read only" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    return alertController;
}

- (EKEventEditViewController *)editViewControllerForTodoEvent:(TodoEvent *)todoEvent
{
    EKEventEditViewController *editViewController = [[EKEventEditViewController alloc] init];
    editViewController.eventStore = [EKEventStore sharedEventStore];
    editViewController.event = todoEvent.event;
    editViewController.editViewDelegate = self;
    return editViewController;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"Missed events (%ld)", (long)self.todoEventsCache.countOfTodoEvents];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Close"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(closeButtonPressed:)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60;
    self.tableView.separatorColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[VIKTodoEventCell class] forCellReuseIdentifier:@"Cell"];
    
    [self.todoEventsCache addObserver:self forKeyPath:NSStringFromSelector(@selector(todoEvents)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)dealloc
{
    [self.todoEventsCache removeObserver:self forKeyPath:NSStringFromSelector(@selector(todoEvents))];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(todoEvents))]) {
        self.title = [NSString stringWithFormat:@"Missed events (%ld)", (long)self.todoEventsCache.countOfTodoEvents];
        
        // TODO: Extract to cache result controller
        NSArray *old = [change objectForKey:@"old"];
        NSArray *new = [change objectForKey:@"new"];
        
        // Old
        // - Test
        // - Boka Berlin
        
        // New
        // - Boka Berlin
        
        [self.tableView beginUpdates];
        [old enumerateObjectsUsingBlock:^(TodoEvent *todoEvent, NSUInteger index, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            // Delete
            if (![new containsObject:todoEvent]) {
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            // Update
            if ([new containsObject:todoEvent]) {
                NSUInteger newIndex = [new indexOfObject:todoEvent];
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
                if ([indexPath isEqual:newIndexPath]) {
                    [self configureCell:(VIKTodoEventCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
                }
            }
            
            // TODO: Move?
            
        }];
        [new enumerateObjectsUsingBlock:^(TodoEvent *todoEvent, NSUInteger index, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            // Insert
            if (![old containsObject:todoEvent]) {
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
        [self.tableView endUpdates];
    }
}

#pragma mark - Actions

- (void)closeButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(missedEventsViewControllerDidFinish:)]) {
        [self.delegate missedEventsViewControllerDidFinish:self];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.todoEventsCache.countOfTodoEvents;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VIKTodoEventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(VIKTodoEventCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    TodoEvent *todoEvent = [self.todoEventsCache objectInTodoEventsAtIndex:indexPath.row];
    cell.titleText = todoEvent.title;
    cell.detailText = todoEvent.timeAgo;
    cell.delegate = self;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TodoEvent *todoEvent = [self.todoEventsCache objectInTodoEventsAtIndex:indexPath.row];
    // FIXME: Uuuuuuuugly
    DetailViewController *vc = [[DetailViewController alloc] init];
    vc.todoEvent = todoEvent;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
    return;
    
    UIViewController *viewController;
    if (todoEvent.allowsContentModifications) {
        viewController = [self editViewControllerForTodoEvent:todoEvent];
    } else {
        viewController = [self readOnlyAlertController];
    }
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    // Make sure it only run once. Apple bug.
    controller.editViewDelegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - VIKTodoEventCellDelegate

- (void)todoEventCellDidToggleComplete:(VIKTodoEventCell *)todoEventCell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:todoEventCell];
    TodoEvent *todoEvent = [self.todoEventsCache objectInTodoEventsAtIndex:indexPath.row];
    todoEvent.completed = @YES;
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

- (void)todoEventCellDidToggleDelete:(VIKTodoEventCell *)todoEventCell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:todoEventCell];
    TodoEvent *todoEvent = [self.todoEventsCache objectInTodoEventsAtIndex:indexPath.row];

    DeleteTodoEventAlert *deleteTodoEventFactory = [[DeleteTodoEventAlert alloc] initWithTodoEvent:todoEvent];
    deleteTodoEventFactory.delegate = self;
    [self presentViewController:deleteTodoEventFactory.alertController animated:YES completion:nil];
}

#pragma mark - DeleteTodoEventAlertDelegate

- (void)deleteTodoEventAlertThis:(TodoEvent *)todoEvent
{
    [[Analytics sharedAnalytics] track:@"Deleted Event" properties:@{ @"screen": @"Missed Events", @"swipe": @YES, @"Days From Now": [NSNumber numberWithInteger:[[NSDate date] daysAfterDate:todoEvent.startDate]] }];
    [todoEvent deleteThisEvent];
}
- (void)deleteTodoEventAlertFuture:(TodoEvent *)todoEvent
{
    [[Analytics sharedAnalytics] track:@"Deleted Event" properties:@{ @"screen": @"Missed Events", @"swipe": @YES, @"Days From Now": [NSNumber numberWithInteger:[[NSDate date] daysAfterDate:todoEvent.startDate]] }];
    [todoEvent deleteFutureEvents];
}

@end
