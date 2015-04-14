//
//  TodoEventTableViewCell.h
//  Daily
//
//  Created by Viktor Fröberg on 09/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TodoEventTableViewCellDelegate;

@interface TodoEventTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, weak) id<TodoEventTableViewCellDelegate> delegate;

- (void)applyCompletedStyle;
- (void)applyIncompletedStyle;

@end

@protocol TodoEventTableViewCellDelegate <NSObject>

- (void)todoEventTableViewCell:(TodoEventTableViewCell *)cell didToggleCheckbox:(BOOL)checked;

@end
