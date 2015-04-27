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

@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSArray *items;

@property (nonatomic, strong) DateHeaderView *headerView;

@property (nonatomic, strong) NSIndexPath *startIndexPath;

@end

@implementation ListViewController

#pragma mark - Properties

- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
    NSArray *newItems = [items sortedArrayUsingDescriptors:[self sortDescriptors]];
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

#pragma mark - Lifecycle

- (instancetype)initWithDate:(NSDate *)date items:(NSArray *)items
{
    NSParameterAssert(date);
    NSParameterAssert(items);
    
    self = [super init];
    if (self) {
        _date = date;
        _items = [items sortedArrayUsingDescriptors:[self sortDescriptors]];
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

- (void)animateChanges:(NSArray *)changes
{
    [changes each:^(ArrayChange *change) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:change.index inSection:0];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:change.newIndex inSection:0];
        
        switch (change.type) {
            case ArrayChangeInsert:
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case ArrayChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case ArrayChangeMove:
                [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
                break;
            case ArrayChangeUpdate:
                [self configureCell:(TodoEventTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] item:[self todoEventAtIndexPath:newIndexPath]];
                break;
        }
        
    }];
}


#pragma mark - UITableViewDataSource

- (void)configureCell:(TodoEventTableViewCell *)cell item:(TodoEvent *)item
{
    TodoEventViewModel *viewModel = [[TodoEventViewModel alloc] initWithTodoEvent:item];
    [cell configureWithViewModel:viewModel delegate:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
    TodoEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell item:todoEvent];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static TodoEventTableViewCell *sizingCell;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [[TodoEventTableViewCell alloc] init];
    });
    
    TodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
    TodoEventViewModel *viewModel = [[TodoEventViewModel alloc] initWithTodoEvent:todoEvent];
    [sizingCell configureWithViewModel:viewModel delegate:nil];
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    return sizingCell.estimatedHeight;
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
    if (!self.startIndexPath)
        self.startIndexPath = fromIndexPath;
    
    self.items = [self.items arrayByMovingObjectAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
    NSLog(@"%@", [self.items valueForKey:@"title"]);
}

- (void)tableView:(UITableView *)tableView didEndReorderingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.startIndexPath isEqual:indexPath]) {
        TodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
        TodoEvent *todoEventSibling = [self todoEventSibling:todoEvent];
        
        NSDictionary *updatedValues = @{@"completed": @(todoEventSibling.completed)};
        TodoEvent *updatedTodoEvent = [todoEvent modelByAddingEntriesFromDictionary:updatedValues error:nil];
        
        NSArray *updatedItems = [[self.items
            arrayByReplacingObjectAtIndex:indexPath.row withObject:updatedTodoEvent]
            arrayByMappingIndexed:^TodoEvent *(TodoEvent *todoEvent, NSUInteger idx) {
                return [todoEvent modelByAddingEntriesFromDictionary:@{@"position": @(idx)} error:nil];
            }];

        self.items = updatedItems;
        [[TodoEventAPI sharedInstance] updateTodoEvents:self.items completion:nil];
    }
    
    self.startIndexPath = nil;
}


#pragma mark - TodoEventTableViewCellDelegate

- (void)todoEventTableViewCellDidToggleCheckbox:(TodoEventTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    TodoEvent *todoEvent = [self.items objectAtIndex:indexPath.row];
    
    NSDictionary *updatedValues = @{@"completed": todoEvent.completed ? @NO : @YES,
                                    @"position": todoEvent.completed ? @(INT_MAX) : @0};
    TodoEvent *updatedTodoEvent = [todoEvent modelByAddingEntriesFromDictionary:updatedValues error:nil];
    
    NSArray *updatedItems = [[[self.items
        arrayByReplacingObjectAtIndex:indexPath.row withObject:updatedTodoEvent]
        arraySortedByKeys:@[@"completed", @"position"] ascending:YES]
        arrayByMappingIndexed:^TodoEvent *(TodoEvent *todoEvent, NSUInteger idx) {
            return [todoEvent modelByAddingEntriesFromDictionary:@{@"position": @(idx)} error:nil];
        }];
    
    [self setItems:updatedItems animated:YES];
    
    [[TodoEventAPI sharedInstance] updateTodoEvents:updatedItems completion:nil];
}

#pragma mark - Helpers (Extract if possible)

- (NSArray *)sortDescriptors
{
    NSSortDescriptor *completionSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"completed" ascending:YES];
    NSSortDescriptor *positionSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
    return @[completionSortDescriptor, positionSortDescriptor];
}

- (TodoEvent *)todoEventSibling:(TodoEvent *)todoEvent
{
    if (todoEvent.completed) {
        return [self todoEventAfter:todoEvent];
    } else {
        return [self todoEventBefore:todoEvent];
    }
}

- (TodoEvent *)todoEventAfter:(TodoEvent *)todoEvent
{
    NSInteger index = [self.items indexOfObject:todoEvent];
    NSInteger max = self.items.count - 1;
    NSInteger newIndex = MIN(index + 1, max); // Use the lowest
    return [self.items objectAtIndex:newIndex];
}

- (TodoEvent *)todoEventBefore:(TodoEvent *)todoEvent
{
    NSInteger index = [self.items indexOfObject:todoEvent];
    NSInteger newIndex = MAX(index - 1, 0); // Use the biggest
    return [self.items objectAtIndex:newIndex];
}

- (TodoEvent *)todoEventAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.items objectAtIndex:indexPath.row];
}

@end

