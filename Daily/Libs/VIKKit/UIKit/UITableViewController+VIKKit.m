
//
//  VIKTableViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 16/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "UITableViewController+VIKKit.h"

@implementation UITableViewController (VIKKit)

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:[self tableViewEdgeInsets]];
    }

    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:[self tableViewEdgeInsets]];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:[self tableViewEdgeInsets]];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:[self tableViewEdgeInsets]];
    }
}

- (UIEdgeInsets)tableViewEdgeInsets
{
    return UIEdgeInsetsZero;
}

@end
