//
//  ListViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 20/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "ListViewController.h"

// Models
#import "TodoEvent.h"

// View Models
#import "TodoEventViewModel.h"

// Views
#import "HPReorderTableView.h"
#import "DateHeaderView.h"
#import "TodoEventTableViewCell.h"

// Controllers
#import "DetailViewController.h"

// Other
#import "MagicTableViewDataSource.h"
#import "TodoEventAPI.h"

@interface ListViewController () <HPReorderTableViewDelegate, TodoEventTableViewCellDelegate, MagicTableViewDataSourceDelegate>

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSIndexPath *startIndexPath;
@property (nonatomic, strong) DateHeaderView *headerView;
@property (nonatomic, strong) MagicTableViewDataSource *dataSource;

@end

@implementation ListViewController

#pragma mark - Life Cycle

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
    
    self.tableView.estimatedRowHeight = 60.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    
    [self.tableView registerClass:[TodoEventTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.dataSource = [[MagicTableViewDataSource alloc] initWithTableView:self.tableView cellIdentifier:@"Cell"];
    self.dataSource.delegate = self;
    
    self.headerView = [[DateHeaderView alloc] init];
    self.headerView.frame = CGRectMake(0, 0, 320, 150);
    self.tableView.tableHeaderView = self.headerView;
}


#pragma mark - Public methods

- (void)setScrollEnable:(BOOL)enabled
{
    self.tableView.showsVerticalScrollIndicator = enabled;
    self.tableView.scrollEnabled = enabled;
}

- (void)configureWithDate:(NSDate *)date todoEvents:(NSArray *)todoEvents
{
    self.date = date;
    [self.headerView configureWithDate:date];
    [self.dataSource configureWithItems:[self sortedTodoEvents:todoEvents]];
}


#pragma mark - MagicTableViewDataSourceDelegate

- (void)configureCell:(TodoEventTableViewCell *)cell item:(TodoEvent *)item
{
    TodoEventViewModel *viewModel = [[TodoEventViewModel alloc] initWithTodoEvent:item];
    cell.delegate = self;
    [cell configureWithTitle:viewModel.titleText time:viewModel.timeText completed:viewModel.completed];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
    
    DetailViewController *vc = [[DetailViewController alloc] initWithTodoEvent:todoEvent];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nc animated:YES completion:^{
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    self.dataSource.changeIsUserDriven = YES;
    
    if (!self.startIndexPath) {
        self.startIndexPath = fromIndexPath;
    }
    
    NSMutableArray *todoEvents = [self.todoEvents mutableCopy];
    TodoEvent *todoEvent = [self todoEventAtIndexPath:fromIndexPath];
    [todoEvents removeObjectAtIndex:fromIndexPath.row];
    [todoEvents insertObject:todoEvent atIndex:toIndexPath.row];
    
    [self.dataSource configureWithItems:[todoEvents copy]];
}


#pragma mark - HPReorderTableViewDelegate

- (void)tableView:(UITableView *)tableView didEndReorderingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.startIndexPath isEqual:indexPath]) {
        
        TodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
        TodoEvent *todoEventSibling = [self todoEventSibling:todoEvent];
        todoEvent.completed = todoEventSibling.completed;

        [self.todoEvents enumerateObjectsUsingBlock:^(TodoEvent *todoEvent, NSUInteger index, BOOL *stop) {
            todoEvent.position = index;
        }];
        
        [[TodoEventAPI sharedInstance] updateTodoEvents:self.todoEvents completion:nil];
    }
    
    self.dataSource.changeIsUserDriven = NO;
    self.startIndexPath = nil;
}


#pragma mark - TodoEventTableViewCellDelegate

- (void)todoEventTableViewCellDidToggleCheckbox:(TodoEventTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    TodoEvent *todoEvent = [self todoEventAtIndexPath:indexPath];
    
    if (todoEvent.completed) {
        todoEvent.completed = NO;
        todoEvent.position = INT_MAX;
    } else {
        todoEvent.completed = YES;
        todoEvent.position = 0;
    }
    
    NSArray *sortedObjects = [self sortedTodoEvents:self.todoEvents];
    [sortedObjects enumerateObjectsUsingBlock:^(TodoEvent *todoEvent, NSUInteger index, BOOL *stop) {
        todoEvent.position = index;
    }];
    
    [[TodoEventAPI sharedInstance] updateTodoEvents:self.todoEvents completion:nil];

}


#pragma mark - Helpers

- (NSArray *)sortedTodoEvents:(NSArray *)todoEvents
{
    NSSortDescriptor *completionSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"completed" ascending:YES];
    NSSortDescriptor *positionSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
    return [todoEvents sortedArrayUsingDescriptors:@[completionSortDescriptor, positionSortDescriptor]];
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
    NSInteger index = [self.todoEvents indexOfObject:todoEvent];
    NSInteger max = self.todoEvents.count - 1;
    NSInteger newIndex = MIN(index + 1, max); // Use the lowest
    return [self.todoEvents objectAtIndex:newIndex];
}

- (TodoEvent *)todoEventBefore:(TodoEvent *)todoEvent
{
    NSInteger index = [self.todoEvents indexOfObject:todoEvent];
    NSInteger newIndex = MAX(index - 1, 0); // Use the biggest
    return [self.todoEvents objectAtIndex:newIndex];
}

- (NSArray *)todoEvents
{
    return self.dataSource.items;
}

- (TodoEvent *)todoEventAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource itemAtIndexPath:indexPath];
}

@end
