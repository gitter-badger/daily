//
//  EventCell.h
//  Prune
//
//  Created by Viktor Fröberg on 15/08/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"

@class TodoEvent;

@interface EventCell : MCSwipeTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;

- (instancetype)setTitle:(NSString *)title time:(NSString *)time location:(NSString *)location;
- (instancetype)eventCellFromTodoEvent:(TodoEvent *)todoEvent;

- (void)missedCell;
- (void)incompleteCell;
- (void)completeCell;

@end