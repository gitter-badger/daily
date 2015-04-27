//
//  TableViewController.h
//  Daily
//
//  Created by Viktor Fröberg on 21/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPReorderTableView.h"

typedef UITableViewCell *(^TableViewCellBlock)(UITableView *tableView, NSIndexPath *indexPath, id item);

@interface TableViewController : UITableViewController

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, strong) TableViewCellBlock cellBlock;

@property (nonatomic, weak) id <HPReorderTableViewDelegate> delegate;

- (void)setItems:(NSArray *)items animated:(BOOL)animated map:(TableViewCellBlock)cellBlock;

@end
