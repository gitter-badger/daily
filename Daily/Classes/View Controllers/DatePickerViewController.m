//
//  DatePickerViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 19/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "DatePickerViewController.h"
#import "DatePickerView.h"

@interface DatePickerViewController () <RSDFDatePickerViewDelegate, RSDFDatePickerViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) DatePickerView *datePickerView;

@end

@implementation DatePickerViewController

- (void)setScrollEnabled:(BOOL)enabled
{
    [self.datePickerView setScrollEnabled:enabled];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarTappedAction:) name:@"statusBarTappedNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listViewChangedDate:) name:@"listViewChangedDate" object:nil];
    
    self.view.backgroundColor = [UIColor blackColor];
    CGRect frame = self.view.bounds;
    
    self.datePickerView = [[DatePickerView alloc] initWithFrame:frame];
    self.datePickerView.delegate = self;
    self.datePickerView.dataSource = self;
    [self.datePickerView selectDate:[NSDate date]];
    
    [self.view addSubview:self.datePickerView];
}

- (void)listViewChangedDate:(NSNotification *)notification
{
    NSDate *date = notification.object;
    [self.datePickerView selectDate:date];
    [self.datePickerView scrollToDate:date animated:NO];
}

- (void)statusBarTappedAction:(NSNotification *)notificaiton
{
    [self.datePickerView scrollToDate:[NSDate date] animated:NO];
    [self.datePickerView selectDate:[NSDate date]];
}

- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"datePickerViewDidSelectDate" object:date];
    [self.datePickerView scrollToDate:date animated:NO];
}

@end
