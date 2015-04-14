//
//  ListViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 20/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "TodoEventActions.h"
#import "VIKArrayController.h"

// Models
#import "MutableTodoEvent.h"
#import "TodoEventViewModel.h"
#import "TodoEventStore.h"

// Views
#import "DateHeaderView.h"
#import "TodoEventTableViewCell.h"
#import "HPReorderTableView.h"

// Controllers
#import "ListViewController.h"
#import "DetailViewController.h"

@interface ListViewController () <VIKArrayControllerDelegate, HPReorderTableViewDelegate, TodoEventTableViewCellDelegate>

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSMutableArray *cellControllers;

@property (nonatomic, strong) NSIndexPath *startIndexPath;

@property (nonatomic) BOOL changeIsUserDriven;

@property (nonatomic, strong) VIKArrayController *controller;

@end

@implementation ListViewController

- (NSMutableArray *)cellControllers
{
    if (!_cellControllers) {
        _cellControllers = [[NSMutableArray alloc] init];
    }
    return _cellControllers;
}

- (void)setScrollEnable:(BOOL)enabled
{
    self.tableView.scrollEnabled = enabled;
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

- (void)loadView
{
    HPReorderTableView *tableView = [[HPReorderTableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    self.view = tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
    self.tableView.separatorColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableHeaderView = [self dateHeader];
    
    self.controller = [[VIKArrayController alloc] init];
    self.controller.delegate = self;
    
    [self.tableView registerClass:[TodoEventTableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)setTodoEvents:(NSArray *)todoEvents
{
    self.controller.objects = [self sortedTodoEvents:todoEvents];
}

- (NSArray *)sortedTodoEvents:(NSArray *)todoEvents
{
    NSSortDescriptor *completionSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"completed" ascending:YES];
    NSSortDescriptor *positionSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
    return [todoEvents sortedArrayUsingDescriptors:@[completionSortDescriptor, positionSortDescriptor]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.controller numberOfObjects];
}

- (TodoEventTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TodoEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setDelegate:self];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(TodoEventTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MutableTodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
    TodoEventViewModel *viewModel = [[TodoEventViewModel alloc] initWithTodoEvent:todoEvent];
    [cell setTitleText:viewModel.titleText timeText:viewModel.timeText locationText:viewModel.locationText completed:viewModel.completed];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MutableTodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
    if (!todoEvent.allDay) {
        return 88;
    }
    return 60;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MutableTodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
    DetailViewController *vc = [[DetailViewController alloc] initWithTodoEvent:todoEvent];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    self.changeIsUserDriven = YES;
    
    if (!self.startIndexPath) {
        self.startIndexPath = fromIndexPath;
    }
    
    NSMutableArray *todoEvents = [self.controller.objects mutableCopy];
    MutableTodoEvent *todoEvent = [self todoEventAtIndexPath:fromIndexPath];
    [todoEvents removeObjectAtIndex:fromIndexPath.row];
    [todoEvents insertObject:todoEvent atIndex:toIndexPath.row];
    
    self.controller.objects = [todoEvents copy];
}


#pragma mark - TodoEventTableViewCellDelegate

- (void)todoEventTableViewCellDidToggleCheckbox:(TodoEventTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    MutableTodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
    
    if (todoEvent.completed) {
        todoEvent.completed = NO;
        todoEvent.position = INT_MAX;
    } else {
        todoEvent.completed = YES;
        todoEvent.position = 0;
    }
    
    NSArray *sortedObjects = [self sortedTodoEvents:self.controller.objects];
    [sortedObjects enumerateObjectsUsingBlock:^(MutableTodoEvent *todoEvent, NSUInteger index, BOOL *stop) {
        todoEvent.position = index;
    }];
    
    [[TodoEventActions sharedActions] updateTodoEvents:self.controller.objects];
}


#pragma mark - HPReorderTableViewDelegate

- (void)tableView:(UITableView *)tableView didEndReorderingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.startIndexPath isEqual:indexPath]) {
        
        MutableTodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
        MutableTodoEvent *todoEventSibling = [self todoEventSibling:todoEvent];
        todoEvent.completed = todoEventSibling.completed;

        [self.controller.objects enumerateObjectsUsingBlock:^(MutableTodoEvent *todoEvent, NSUInteger index, BOOL *stop) {
            todoEvent.position = index;
        }];
        
        [[TodoEventActions sharedActions] updateTodoEvents:self.controller.objects];
    }
    
    self.changeIsUserDriven = NO;
    self.startIndexPath = nil;
}

- (MutableTodoEvent *)todoEventSibling:(MutableTodoEvent *)todoEvent
{
    if (todoEvent.completed) {
        return [self todoEventAfter:todoEvent];
    } else {
        return [self todoEventBefore:todoEvent];
    }
}

- (MutableTodoEvent *)todoEventAfter:(MutableTodoEvent *)todoEvent
{
    NSInteger index = [self.controller.objects indexOfObject:todoEvent];
    NSInteger max = self.controller.numberOfObjects - 1;
    NSInteger newIndex = MIN(index + 1, max); // Use the lowest
    return [self.controller.objects objectAtIndex:newIndex];
}

- (MutableTodoEvent *)todoEventBefore:(MutableTodoEvent *)todoEvent
{
    NSInteger index = [self.controller.objects indexOfObject:todoEvent];
    NSInteger newIndex = MAX(index - 1, 0); // Use the biggest
    return [self.controller.objects objectAtIndex:newIndex];
}


#pragma mark - VIKArrayControllerDelegate

- (void)controllerWillChangeContent:(VIKArrayController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(VIKArrayController *)controller didChangeObject:(id)anObject atIndex:(NSUInteger)index forChangeType:(VIKArrayChangeType)type newIndex:(NSUInteger)newIndex
{
    if (self.changeIsUserDriven) return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
    
    switch (type) {
        case VIKArrayChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case VIKArrayChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case VIKArrayChangeMove:
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        case VIKArrayChangeUpdate:
            [self configureCell:(TodoEventTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:newIndexPath];
            break;
    }
}

- (void)controllerDidChangeContent:(VIKArrayController *)controller
{
    [self.tableView endUpdates];
}


#pragma mark - Helpers

- (DateHeaderView *)dateHeader
{
    DateHeaderView *dateHeaderView = [[DateHeaderView alloc] initWithDate:self.date];
    dateHeaderView.frame = CGRectMake(0, 0, 320, 150);
    return dateHeaderView;
}

- (MutableTodoEvent *)todoEventAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.controller.objects objectAtIndex:indexPath.row];
}

@end
