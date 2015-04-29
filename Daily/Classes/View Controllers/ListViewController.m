//
//  EXPListViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 19/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "NSArray+Changes.h"

// Stores
#import "TodoEventAPI.h"

// Models
#import "TodoEvent.h"
#import "TodoEventViewModel.h"

// Controllers
#import "ListViewController.h"
#import "DetailViewController.h"

// Views
#import "DateHeaderView.h"
#import "TodoEventTableViewCell.h"
#import "HPReorderTableView.h"

@interface ListViewController () <HPReorderTableViewDelegate, TodoEventTableViewCellDelegate>

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, strong) NSIndexPath *startIndexPath;

@property (nonatomic, strong) DateHeaderView *headerView;

@end

@implementation ListViewController

#pragma mark - Lifecycle

- (instancetype)initWithDate:(NSDate *)date items:(NSArray *)items
{
    NSParameterAssert(date);
    NSParameterAssert(items);
    
    self = [super init];
    if (self) {
        _date = date;
        _items = [items arraySortedByKeys:self.sortKeys ascending:YES];
    }
    return self;
}

#pragma mark - UITableViewController

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
    
    // TableView
    self.tableView.rowHeight = 60.0;
    self.tableView.separatorColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    self.tableView.scrollEnabled = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView registerClass:[TodoEventTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    // HeaderView
    self.headerView = [[DateHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 150)];
    self.headerView.date = self.date;
    self.tableView.tableHeaderView = self.headerView;
}

#pragma mark - UITableViewUpdates

- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
    NSArray *newItems = [items arraySortedByKeys:self.sortKeys ascending:YES];
    NSArray *changes = [self.items changesComparedToArray:newItems];
    
    if (!changes.count) return;
    
    if (animated) {
        [self.tableView beginUpdates];
        self.items = newItems;
        [self animateChanges:changes];
        [self.tableView endUpdates];
    } else {
        self.items = newItems;
        [self.tableView reloadData];
    }
}

- (void)animateChanges:(NSArray *)changes
{
    [changes each:^(ArrayChange *change) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:change.index inSection:0];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:change.newIndex inSection:0];
        
        switch (change.type) {
            case ArrayChangeInsert:
                [self.tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case ArrayChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case ArrayChangeMove:
                [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
                break;
            case ArrayChangeUpdate:
                [self configureCell:(TodoEventTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] viewModel:[self viewModelForIndexPath:newIndexPath]];
                break;
        }
        
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TodoEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell viewModel:[self viewModelForIndexPath:indexPath]];
    return cell;
}

- (void)configureCell:(TodoEventTableViewCell *)cell viewModel:(TodoEventViewModel *)viewModel
{
    [cell configureWithViewModel:viewModel delegate:self];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static TodoEventTableViewCell *sizingCell;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [[TodoEventTableViewCell alloc] init];
    });
    
    [sizingCell configureWithViewModel:[self viewModelForIndexPath:indexPath] delegate:nil];
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    return [sizingCell estimatedHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
    DetailViewController *vc = [[DetailViewController alloc] initWithTodoEvent:todoEvent];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nc animated:YES completion:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    self.startIndexPath = self.startIndexPath ?: fromIndexPath;
    
    self.items = [self.items arrayByMovingObjectAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

- (void)tableView:(UITableView *)tableView didEndReorderingRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.startIndexPath = nil;
    
    if ([self.startIndexPath isEqual:indexPath]) return;
    
    TodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
    TodoEvent *todoEventSibling = [self todoEventSibling:todoEvent];
    
    NSDictionary *updatedValues = @{ @"completed": @(todoEventSibling.completed) };
    TodoEvent *updatedTodoEvent = [todoEvent modelByAddingEntriesFromDictionary:updatedValues error:nil];
    
    NSArray *updatedItems = [[self.items
        arrayByReplacingObjectAtIndex:indexPath.row withObject:updatedTodoEvent]
        arrayByMappingIndexed:^TodoEvent *(TodoEvent *todoEvent, NSUInteger idx) {
            return [todoEvent modelByAddingEntriesFromDictionary:@{ @"position": @(idx) } error:nil];
        }];

    self.items = updatedItems;
    
    [[TodoEventAPI sharedInstance] updateTodoEvents:self.items completion:nil];
}


#pragma mark - TodoEventTableViewCellDelegate

- (void)todoEventTableViewCellDidToggleCheckbox:(TodoEventTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    TodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
    
    NSDictionary *updatedValues = @{ @"completed": todoEvent.completed ? @NO : @YES,
                                     @"position": todoEvent.completed ? @(INT_MAX) : @0 };
    TodoEvent *updatedTodoEvent = [todoEvent modelByAddingEntriesFromDictionary:updatedValues error:nil];
    
    NSArray *updatedItems = [[[self.items
        arrayByReplacingObjectAtIndex:indexPath.row withObject:updatedTodoEvent]
        arraySortedByKeys:self.sortKeys ascending:YES]
        arrayByMappingIndexed:^TodoEvent *(TodoEvent *todoEvent, NSUInteger idx) {
            return [todoEvent modelByAddingEntriesFromDictionary:@{ @"position": @(idx) } error:nil];
        }];
    
    [self setItems:updatedItems animated:YES];
    
    [[TodoEventAPI sharedInstance] updateTodoEvents:updatedItems completion:nil];
}

- (NSArray *)sortKeys
{
    return @[ @"completed", @"position" ];
}

- (TodoEvent *)todoEventSibling:(TodoEvent *)todoEvent
{
    if (todoEvent.completed) {
        return [self.items objectNextToObject:todoEvent];
    } else {
        return [self.items objectPreviousToObject:todoEvent];
    }
}

- (TodoEventViewModel *)viewModelForIndexPath:(NSIndexPath *)indexPath
{
    TodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
    return [[TodoEventViewModel alloc] initWithTodoEvent:todoEvent];
}

- (TodoEvent *)todoEventFromCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    return [self todoEventAtIndexPath:indexPath];
}

- (TodoEvent *)todoEventAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.items objectAtIndex:indexPath.row];
}

@end

