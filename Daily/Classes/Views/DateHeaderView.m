//
//  DateHeaderView.m
//  Daily
//
//  Created by Viktor Fröberg on 20/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "DateHeaderView.h"

#import "NSDateFormatter+Extended.h"

@interface DateHeaderView ()

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *cornerBackground;

@end

@implementation DateHeaderView

- (void)setDate:(NSDate *)date
{
    self.titleLabel.text = [[[NSDateFormatter relativeWeekDayFormatterFromDate:date] stringFromDate:date] capitalizedString];
    self.detailLabel.text = [[[NSDateFormatter fullDateFormatter] stringFromDate:date] uppercaseString];
}

- (UIView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        _backgroundView.layer.cornerRadius = 5;
    }
    return _backgroundView;
}

- (UIView *)cornerBackground
{
    if (!_cornerBackground) {
        _cornerBackground = [[UIView alloc] init];
        _cornerBackground.backgroundColor = [UIColor blackColor];
    }
    return _cornerBackground;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:24];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textColor = [UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1];
        _detailLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:14];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _detailLabel;
}

- (UIView *)shadowView
{
    if (!_shadowView) {
        _shadowView = [[UIView alloc] init];
        _shadowView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    }
    return _shadowView;
}

#pragma mark - Life Cycle

- (instancetype)initWithDate:(NSDate *)date
{
    self = [super init];
    if (self) {
        self.date = date;
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];

    [self addSubview:self.cornerBackground];
    [self addSubview:self.backgroundView];
    [self addSubview:self.contentView];
    [self addSubview:self.shadowView];
}

- (void)layoutSubviews
{
    self.backgroundView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.cornerBackground.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 10);
    
    self.titleLabel.frame = CGRectMake(0, 0, self.bounds.size.width, 36);
    self.detailLabel.frame = CGRectMake(0, self.titleLabel.frame.size.height, self.bounds.size.width, 30);
    
    CGRect frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    frame.size.height = self.titleLabel.frame.size.height + self.detailLabel.frame.size.height;
    frame.origin.y = (self.bounds.size.height - frame.size.height) / 2;
    self.contentView.frame = frame;
    
    self.shadowView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, .5);
}

@end
