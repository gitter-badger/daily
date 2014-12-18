//
//  VIKTodoEventCell.m
//  Daily
//
//  Created by Viktor Fröberg on 10/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "VIKTodoEventCell.h"

@implementation VIKTodoEventCell

#pragma mark - Public

- (void)setTitleText:(NSString *)titleText
{
    self.textLabel.text = titleText;
}

- (void)setDetailText:(NSString *)detailText
{
    self.detailTextLabel.text = detailText;
}

#pragma mark - Life cycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setup];
}

- (void)setup
{
    __weak typeof(self)welf = self;
    [self setSwipeGestureWithView:self.checkView color:self.greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        if ([welf.delegate respondsToSelector:@selector(todoEventCellDidToggleComplete:)]) {
            [welf.delegate todoEventCellDidToggleComplete:(VIKTodoEventCell *)cell];
        }
    }];
    
    [self setSwipeGestureWithView:self.crossView color:self.redColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        if ([welf.delegate respondsToSelector:@selector(todoEventCellDidToggleDelete:)]) {
            [welf.delegate todoEventCellDidToggleDelete:(VIKTodoEventCell *)cell];
        }
    }];
}

#pragma mark - Private

- (CGFloat)firstTrigger
{
    return 0.2;
}

- (UIColor *)defaultColor
{
    return [UIColor lightGrayColor];
}

- (UIColor *)greenColor
{
    return [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
}

- (UIColor *)redColor
{
    return [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];
}

- (UIView *)crossView
{
    return [UIImageView imageViewWithImageName:@"cross"];
}

- (UIView *)checkView
{
    return [UIImageView imageViewWithImageName:@"check"];
}

@end
