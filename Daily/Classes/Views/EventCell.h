//
//  EventCell.h
//  Prune
//
//  Created by Viktor Fröberg on 15/08/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCSwipeTableViewCell.h"

@interface EventCell : MCSwipeTableViewCell

- (instancetype)setTitle:(NSString *)title time:(NSString *)time location:(NSString *)location;

- (instancetype)incompleteCell;
- (instancetype)completeCell;

@end