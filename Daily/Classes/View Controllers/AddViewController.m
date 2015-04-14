//
//  AddViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 13/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "AddViewController.h"
#import "VIKTextFieldCell.h"
#import "EKEventStore+VFDaily.h"

@interface AddViewController () <UITextFieldDelegate>

@property (nonatomic) UIEdgeInsets tableViewEdgeInsets;

@end

@implementation AddViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Add item";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
    [self.tableView registerClass:[VIKTextFieldCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableViewEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.layer.cornerRadius = 5;
    self.tableView.rowHeight = 46;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRect frame = self.tableView.tableHeaderView.frame;
    frame.size.height = 1;
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    [self.tableView setTableHeaderView:headerView];
    
    VIKTextFieldCell *titleCell = (VIKTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [titleCell.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:self.tableViewEdgeInsets];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:self.tableViewEdgeInsets];
    }
}

- (void)cancelButtonPressed:(id)sender
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveButtonPressed:(id)sender
{
    VIKTextFieldCell *titleCell = (VIKTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *titleString = titleCell.textField.text;
    
    VIKTextFieldCell *locationCell = (VIKTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    NSString *location = locationCell.textField.text;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [dateFormatter stringFromDate:self.date];
    
    NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
    dateTimeFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    
    NSError *regexError = nil;
    NSRegularExpression *startEndRegex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]{1,2})((\\:|\\.)([0-9]{1,2}))?(\\-)([0-9]{1,2})((\\:|\\.)([0-9]{1,2}))" options:NSRegularExpressionCaseInsensitive error:&regexError];
    NSRegularExpression *startRegex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]{1,2})((\\:|\\.)([0-9]{1,2}))" options:NSRegularExpressionCaseInsensitive error:&regexError];
    if (regexError) {
        NSLog(@"Error: %@", regexError);
    }
    
    NSArray *timeRangeMatches = [startEndRegex matchesInString:titleString options:0 range:NSMakeRange(0, [titleString length])];
    NSArray *timeMatches = [startRegex matchesInString:titleString options:0 range:NSMakeRange(0, [titleString length])];
    
    NSDate *startDate = nil;
    NSDate *endDate = nil;
    NSString *title = [titleString copy];
    
    if (timeRangeMatches.count) {
        NSTextCheckingResult *match = timeRangeMatches.lastObject;
        title = [titleString stringByReplacingCharactersInRange:match.range withString:@""];
        
        NSString *startHour = [titleString substringWithRange:[match rangeAtIndex:1]];
        NSString *startMinutes = [match rangeAtIndex:4].length ? [titleString substringWithRange:[match rangeAtIndex:4]] : @"00";
        NSString *startTime = [NSString stringWithFormat:@"%@ %@:%@", dateString, startHour, startMinutes];
        startDate = [dateTimeFormatter dateFromString:startTime];
        
        NSString *endHour = [titleString substringWithRange:[match rangeAtIndex:6]];
        NSString *endMinutes = [titleString substringWithRange:[match rangeAtIndex:9]];
        NSString *endTime = [NSString stringWithFormat:@"%@ %@:%@", dateString, endHour, endMinutes];
        endDate = [dateTimeFormatter dateFromString:endTime];
    }
    else if (timeMatches.count) {
        NSTextCheckingResult *match = timeMatches.lastObject;
        title = [titleString stringByReplacingCharactersInRange:match.range withString:@""];
        
        NSString *startHour = [titleString substringWithRange:[match rangeAtIndex:1]];
        NSString *startMinutes = [titleString substringWithRange:[match rangeAtIndex:4]];
        NSString *startTime = [NSString stringWithFormat:@"%@ %@:%@", dateString, startHour, startMinutes];
        startDate = [dateTimeFormatter dateFromString:startTime];
    }
    
    EKEventStore *eventStore = [EKEventStore sharedEventStore];
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = [title copy];
    event.allDay = NO;
    event.location = location;
    if (startDate) {
        event.startDate = startDate;
        if (endDate) {
            event.endDate = endDate;
        } else {
            event.endDate = [event.startDate dateByAddingTimeInterval:60*60];
        }
    }
    else {
        event.startDate = self.date;
        event.endDate = [event.startDate dateByAddingTimeInterval:60*60];
        event.allDay = YES;
    }
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    
    NSError *eventStoreError = nil;
    [eventStore saveEvent:event span:EKSpanThisEvent error:&eventStoreError];
    if (eventStoreError) {
        NSLog(@"Error: %@", eventStoreError);
    }
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:self.tableViewEdgeInsets];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:self.tableViewEdgeInsets];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VIKTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            cell.textField.placeholder = @"Buy groceries 10:00";
            break;
        case 1:
            cell.textField.placeholder = @"Location";
            break;
    }
    
    if (indexPath.row < 1) {
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(15, cell.bounds.size.height, self.view.bounds.size.width-30, 1)];
        bottomLineView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        [cell.contentView addSubview:bottomLineView];
    }
    
    cell.textField.delegate = self;
    cell.textField.returnKeyType = UIReturnKeyDone;
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

@end
