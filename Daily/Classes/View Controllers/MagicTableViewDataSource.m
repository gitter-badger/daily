//
//  MagicTableViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 16/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "MagicTableViewDataSource.h"
#import "VIKArrayController.h"

@interface MagicTableViewDataSource () <VIKArrayControllerDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) VIKArrayController *state;

@end

@implementation MagicTableViewDataSource

- (instancetype)initWithTableView:(UITableView *)tableView cellIdentifier:(NSString *)cellIdentifier
{
    self = [super init];
    if (self) {
        tableView.dataSource = self;
        self.tableView = tableView;
        
        self.cellIdentifier = cellIdentifier;
        
        self.state = [[VIKArrayController alloc] init];
        self.state.delegate = self;
    }
    return self;
}

- (NSArray *)items
{
    return self.state.objects;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.state objectAtIndex:indexPath.row];
}

- (void)configureWithItems:(NSArray *)items
{
    self.state.objects = items;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.state numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    [self.delegate configureCell:cell item:item];
    return cell;
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
            [self.delegate configureCell:[self.tableView cellForRowAtIndexPath:indexPath] item:[self itemAtIndexPath:newIndexPath]];
            break;
    }
}

- (void)controllerDidChangeContent:(VIKArrayController *)controller
{
    [self.tableView endUpdates];
}

@end
