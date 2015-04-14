//
//  TodoEventTableViewCell.m
//  Daily
//
//  Created by Viktor Fröberg on 09/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "TodoEventTableViewCell.h"

@interface TodoEventTableViewCell ()

@property (nonatomic, strong) UIButton *checkbox;

@property (nonatomic) BOOL completed;

@end

@implementation TodoEventTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
        
        self.checkbox = [[UIButton alloc] init];
        [self.checkbox addTarget:self action:@selector(checkboxDidReceiveTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.checkbox];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:19];
        [self.contentView addSubview:self.titleLabel];
        
        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:16];
        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}

- (void)checkboxDidReceiveTap:(id)sender
{
    NSLog(@"HÄR?");
    [self.delegate todoEventTableViewCell:self didToggleCheckbox:!self.completed];
}

- (void)applyCompletedStyle
{
    [self.checkbox setImage:[UIImage imageNamed:@"checkbox-on"] forState:UIControlStateNormal];
    
    self.titleLabel.textColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1];
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.titleLabel.text attributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]}];
    
    self.detailLabel.textColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1];
    self.detailLabel.attributedText = [[NSAttributedString alloc] initWithString:self.detailLabel.text attributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]}];
    
    self.completed = YES;
}

- (void)applyIncompletedStyle
{
    [self.checkbox setImage:[UIImage imageNamed:@"checkbox-off"] forState:UIControlStateNormal];
    
    self.titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.titleLabel.text attributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleNone]}];
    
    self.detailLabel.textColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1];
    self.detailLabel.attributedText = [[NSAttributedString alloc] initWithString:self.detailLabel.text attributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleNone]}];
    
    self.completed = NO;
}

- (void)layoutSubviews
{
    self.checkbox.frame = CGRectMake(0, 0, 64, CGRectGetHeight(self.bounds));
    
    self.titleLabel.frame = CGRectMake(64, 22, CGRectGetWidth(self.bounds) - 64 - 20, 21);
    
    self.detailLabel.frame = CGRectMake(64, 48, CGRectGetWidth(self.bounds) - 64 - 20, 18);
    
    [super layoutSubviews];
}

@end
