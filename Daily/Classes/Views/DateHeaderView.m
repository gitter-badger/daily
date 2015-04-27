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
        [self configureViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureViews];
    }
    return self;
}

#pragma mark - UIView

- (void)configureViews
{
    self.cornerBackground = [[UIView alloc] init];
    self.cornerBackground.backgroundColor = [UIColor blackColor];
    
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.layer.cornerRadius = 5;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    RAC(self.titleLabel, text) = [RACObserve(self, date) map:^NSString *(NSDate *date) {
        return [[[NSDateFormatter relativeWeekDayFormatterFromDate:date] stringFromDate:date] capitalizedString];
    }];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.textColor = [UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1];
    self.detailLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:14];
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    RAC(self.detailLabel, text) = [RACObserve(self, date) map:^NSString *(NSDate *date) {
        return [[[NSDateFormatter fullDateFormatter] stringFromDate:date] uppercaseString];
    }];
    
    self.contentView = [[UIView alloc] init];
    
    self.shadowView = [[UIView alloc] init];
    self.shadowView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    
    [self.contentView setSubviews:@[self.titleLabel, self.detailLabel]];
    [self setSubviews:@[self.cornerBackground, self.backgroundView, self.contentView, self.shadowView]];
}

- (void)layoutSubviews
{
    self.cornerBackground.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 10);
    
    self.backgroundView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    self.titleLabel.frame = CGRectMake(0, 0, self.bounds.size.width, 36);
    
    self.detailLabel.frame = CGRectMake(0, self.titleLabel.frame.size.height, self.bounds.size.width, 30);
    
    CGRect frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    frame.size.height = self.titleLabel.frame.size.height + self.detailLabel.frame.size.height;
    frame.origin.y = (self.bounds.size.height - frame.size.height) / 2;
    self.contentView.frame = frame;
    
    self.shadowView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, .5);
}

@end
