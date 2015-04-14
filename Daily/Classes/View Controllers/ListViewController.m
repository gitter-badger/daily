//
//  ListViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 20/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "ListViewController.h"
#import "DateHeaderView.h"

#import "DetailViewController.h"
#import "EKEventStore+VFDaily.h"

#import "TodoEvent.h"

#import "TodoEventTableViewCell.h"

#import "TodoEventFetchedResultsController.h"

@interface ListViewController () <UIGestureRecognizerDelegate, TodoEventTableViewCellDelegate, TodoEventFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) TodoEventFetchedResultsController *fetchedResultsController;

@property (nonatomic) UIEdgeInsets tableViewEdgeInsets;

@property (nonatomic, strong) NSMutableArray *incompletedEvents;
@property (nonatomic, strong) NSMutableArray *completedEvents;

@property (nonatomic, strong) DateHeaderView *dateHeaderView;

@end

@implementation ListViewController

@synthesize date = _date;

- (NSDate *)date
{
    if (!_date) {
        _date = [NSDate date];
    }
    return _date;
}

#pragma mark - Life Cycle

- (instancetype)initWithDate:(NSDate *)date
{
    self = [super init];
    if (self) {
        self.date = date;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableViewEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.tableView.rowHeight = 60;
    self.tableView.separatorColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.scrollEnabled = NO;
    
    [self.tableView registerClass:[TodoEventTableViewCell class] forCellReuseIdentifier:@"Cell"];

    self.dateHeaderView = [[DateHeaderView alloc] initWithDate:self.date];
    self.dateHeaderView.frame = CGRectMake(0, 0, 320, 150);
    self.tableView.tableHeaderView = self.dateHeaderView;
    
    self.fetchedResultsController = [[TodoEventFetchedResultsController alloc] initWithStartDate:self.date endDate:self.date];
    self.fetchedResultsController.delegate = self;
}

- (void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:self.tableViewEdgeInsets];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:self.tableViewEdgeInsets];
    }
}

#pragma mark - TodoEventFetchedResultsController

- (void)todoEventControllerWillChangeContent:(TodoEventFetchedResultsController *)controller
{
//    [self.tableView beginUpdates];
    NSLog(@"todoEventControllerWillChangeContent");
}

- (void)todoEventController:(TodoEventFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(TodoEventFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type)
    {
        case TodoEventFetchedResultsChangeInsert:
            NSLog(@"TodoEventFetchedResultsChangeInsert");
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case TodoEventFetchedResultsChangeDelete:
            NSLog(@"TodoEventFetchedResultsChangeDelete");
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case TodoEventFetchedResultsChangeUpdate:
            NSLog(@"TodoEventFetchedResultsChangeUpdate");
            // CONFIGURE CELL
            break;
        case TodoEventFetchedResultsChangeMove:
            NSLog(@"TodoEventFetchedResultsChangeMove");
            NSLog(@"%@, %@, %@", [(TodoEvent *)anObject title], indexPath, newIndexPath);
//            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

- (void)todoEventControllerDidChangeContent:(TodoEventFetchedResultsController *)controller
{
    NSLog(@"todoEventControllerDidChangeContent");
//    [self.tableView endUpdates];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.fetchedResultsController numberOfSections] > 0) {
        TodoEventFetchedResultsSection *sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TodoEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    TodoEvent *todoEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.delegate = self;
    cell.backgroundColor = [UIColor whiteColor];
    cell.titleLabel.text = todoEvent.title;
    cell.detailLabel.text = todoEvent.humanReadableStartTime;
    if (todoEvent.isCompleted) {
        [cell applyCompletedStyle];
    } else {
        [cell applyIncompletedStyle];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TodoEvent *todoEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (!todoEvent.allDay) {
        return 88;
    }
    return 60;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TodoEvent *todoEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    DetailViewController *vc = [[DetailViewController alloc] init];
    vc.todoEvent = todoEvent;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
}


// TODO: Subclass UITableViewController
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:self.tableViewEdgeInsets];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:self.tableViewEdgeInsets];
    }
}

#pragma mark - TodoEventTableViewCellDelegate

- (void)todoEventTableViewCell:(TodoEventTableViewCell *)cell didToggleCheckbox:(BOOL)checked
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    TodoEvent *todoEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if (checked) {
        todoEvent.completed = @YES;
//        [cell applyCompletedStyle];
    } else {
        todoEvent.completed = @NO;
//        [cell applyIncompletedStyle];
    }
    
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

@end
