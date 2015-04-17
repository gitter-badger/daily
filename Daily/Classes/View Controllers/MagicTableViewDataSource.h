//
//  MagicTableViewController.h
//  Daily
//
//  Created by Viktor Fröberg on 16/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MagicTableViewDataSourceDelegate;

@interface MagicTableViewDataSource: NSObject

@property (nonatomic) BOOL changeIsUserDriven;

@property (nonatomic, weak) id <MagicTableViewDataSourceDelegate> delegate;

- (instancetype)initWithTableView:(UITableView *)tableView cellIdentifier:(NSString *)cellIdentifier;

- (NSArray *)items;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

- (void)configureWithItems:(NSArray *)items;

@end

@protocol MagicTableViewDataSourceDelegate <NSObject>

@required
- (void)configureCell:(id)cell item:(id)item;

@end