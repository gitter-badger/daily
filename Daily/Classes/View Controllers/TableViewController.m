//
//  TableViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 21/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "TableViewController.h"
#import "NSArray+Changes.h"

@interface TableViewController () <HPReorderTableViewDelegate>

@end

@implementation TableViewController

#pragma mark - Public methods

- (void)setItems:(NSArray *)items animated:(BOOL)animated map:(TableViewCellBlock)cellBlock
{
    self.cellBlock = cellBlock;
    
    if ([self.items isEqual:items]) return;
    
    if (!animated || !self.items) {
        self.items = items;
        [self.tableView reloadData];
    } else {
        NSArray *changes = [self.items changesComparedToArray:items];
        if (changes) {
            [self.tableView beginUpdates];
            self.items = items;
            [self animateChanges:changes];
            [self.tableView endUpdates];
        }
    }
}

- (void)setDelegate:(id<HPReorderTableViewDelegate>)delegate
{
    self.tableView.delegate = delegate;
}

#pragma mark - Life cycle

- (void)loadView
{
    HPReorderTableView *tableView = [[HPReorderTableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    self.view = tableView;
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
    id item = [self itemAtIndexPath:indexPath];
    return self.cellBlock(tableView, indexPath, item);
}

#pragma mark - Helpers

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.items objectAtIndex:indexPath.row];
}

- (void)animateChanges:(NSArray *)changes
{
    // [tableview performUpdates:updates];
    
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
                [self.tableView reloadRowsAtIndexPaths:@[newIndexPath]withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
        }
        
    }];
}

@end
