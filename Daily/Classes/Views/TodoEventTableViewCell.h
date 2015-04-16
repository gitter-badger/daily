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

@property (nonatomic, weak) id<TodoEventTableViewCellDelegate> delegate;

- (void)configureWithTitle:(NSString *)title time:(NSString *)time completed:(BOOL)completed;

@end

@protocol TodoEventTableViewCellDelegate <NSObject>

- (void)todoEventTableViewCellDidToggleCheckbox:(TodoEventTableViewCell *)cell;

@end
