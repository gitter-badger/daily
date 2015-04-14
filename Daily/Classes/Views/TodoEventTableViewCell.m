//
//  TodoEventTableViewCell.m
//  Daily
//
//  Created by Viktor Fröberg on 09/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "TodoEventTableViewCell.h"

@interface TodoEventTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *checkboxButton;

@end

@implementation TodoEventTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
        
        self.checkboxButton = [[UIButton alloc] init];
        [self.checkboxButton addTarget:self action:@selector(checkboxDidReceiveTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.checkboxButton];
        
        self.titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.titleLabel];
        
        self.detailLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.detailLabel];
        
        self.titleLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:19];
        self.detailLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:16];
    }
    return self;
}

- (void)setTitleText:(NSString *)titleText timeText:(NSString *)timeText locationText:(NSString *)locationText completed:(BOOL)completed
{
    if (completed) {
        self.titleLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleText attributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]}];
        
        self.detailLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        self.detailLabel.attributedText = [[NSAttributedString alloc] initWithString:timeText attributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]}];
        
        [self.checkboxButton setImage:[UIImage imageNamed:@"checkbox-on"] forState:UIControlStateNormal];
    } else {
        self.titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleText attributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleNone]}];
        
        self.detailLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
        self.detailLabel.attributedText = [[NSAttributedString alloc] initWithString:timeText attributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleNone]}];
        
        [self.checkboxButton setImage:[UIImage imageNamed:@"checkbox-off"] forState:UIControlStateNormal];
    }
}

- (void)checkboxDidReceiveTap:(id)sender
{
    [self.delegate todoEventTableViewCellDidToggleCheckbox:self];
}

- (void)layoutSubviews
{
    self.checkboxButton.frame = CGRectMake(0, 0, 64, CGRectGetHeight(self.bounds));
    
    self.titleLabel.frame = CGRectMake(64, 22, CGRectGetWidth(self.bounds) - 64 - 20, 21);
    
    self.detailLabel.frame = CGRectMake(64, 48, CGRectGetWidth(self.bounds) - 64 - 20, 18);
    
    [super layoutSubviews];
}

@end
