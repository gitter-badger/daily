//
//  VIKTodoEventCell.h
//  Daily
//
//  Created by Viktor Fröberg on 10/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCSwipeTableViewCell.h"

@class VIKTodoEventCell;

@protocol VIKTodoEventCellDelegate <MCSwipeTableViewCellDelegate>

@optional

- (void)todoEventCellDidToggleComplete:(VIKTodoEventCell *)todoEventCell;
- (void)todoEventCellDidToggleDelete:(VIKTodoEventCell *)todoEventCell;

@end

@interface VIKTodoEventCell : MCSwipeTableViewCell

@property (nonatomic, weak) id <VIKTodoEventCellDelegate> delegate;

- (void)setTitleText:(NSString *)titleText;
- (void)setDetailText:(NSString *)detailText;

@end
