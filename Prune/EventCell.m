//
//  EventCell.m
//  Prune
//
//  Created by Viktor Fröberg on 15/08/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "EventCell.h"

@interface EventCell ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *location;

@end

@implementation EventCell

- (instancetype)setTitle:(NSString *)title time:(NSString *)time location:(NSString *)location
{
    self.titleLabel.text = @"";
    self.timeLabel.text = @"";
    
    self.title = title;
    self.time = time;
    self.location = location;
    
    self.titleLabel.text = title;
    
    if (time.length && location.length) {
        self.timeLabel.text = [@[time, location] componentsJoinedByString:@" - "];
    }
    else {
        if (time.length) {
            self.timeLabel.text = time;
        }
        else if (location.length) {
            self.timeLabel.text = location;
        }
    }
    
    return self;
}

- (instancetype)eventCellFromTodoEvent:(TodoEvent *)todoEvent
{
    return self;
}

- (void)missedCell
{
    [self applyMissedStyle];
}

- (void)incompleteCell
{
    [self applyIncompleteStyle];
}

- (void)completeCell
{
    [self applyCompleteStyle];
}

- (void)applyMissedStyle
{
    [self applyIncompleteStyle];
    self.titleLabel.textColor = [UIColor greenColor];
}

- (void)applyIncompleteStyle
{
    self.titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    self.titleLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:19];
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.titleLabel.text attributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleNone]}];
    
    self.timeLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    self.timeLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:16];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.timeLabel.text];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, self.time.length)];
    self.timeLabel.attributedText = attributedString;
}

- (void)applyCompleteStyle
{
    self.titleLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    self.titleLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:19];
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.titleLabel.text attributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]}];
    
    self.timeLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    self.timeLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:16];
    self.timeLabel.attributedText = [[NSAttributedString alloc] initWithString:self.timeLabel.text attributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]}];
}

@end
