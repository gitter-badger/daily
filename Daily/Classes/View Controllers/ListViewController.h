//
//  ListViewController.h
//  Daily
//
//  Created by Viktor Fröberg on 19/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UITableViewController

@property (nonatomic, copy, readonly) NSDate *date;

- (instancetype)initWithDate:(NSDate *)date items:(NSArray *)items;
- (void)setItems:(NSArray *)items animated:(BOOL)animated;

@end
