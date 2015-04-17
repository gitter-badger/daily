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

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *cornerBackground;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *shadowView;

@end

@implementation DateHeaderView

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.contentView = [[UIView alloc] init];
    self.cornerBackground = [[UIView alloc] init];
    self.backgroundView = [[UIView alloc] init];
    self.shadowView = [[UIView alloc] init];
    
    self.titleLabel = [[UILabel alloc] init];
    self.detailLabel = [[UILabel alloc] init];
    
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

- (void)configureWithDate:(NSDate *)date
{
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.layer.cornerRadius = 5;
    
    self.cornerBackground.backgroundColor = [UIColor blackColor];
    
    self.titleLabel.text = [[[NSDateFormatter relativeWeekDayFormatterFromDate:date] stringFromDate:date] capitalizedString];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.detailLabel.text = [[[NSDateFormatter fullDateFormatter] stringFromDate:date] uppercaseString];
    self.detailLabel.textColor = [UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1];
    self.detailLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:14];
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    
    self.shadowView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
}

@end
