//
//  AddViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 13/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "AddViewController.h"
#import "TextFieldTableViewCell.h"

#import "TodoEventActions.h"
#import "TodoEvent.h"

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
    [self.tableView registerClass:[TextFieldTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
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
    
    TextFieldTableViewCell *titleCell = (TextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [titleCell.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)cancelButtonPressed:(id)sender
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSDate *)startDateFromString:(NSString *)string
{
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
    NSArray *timeRangeMatches = [startEndRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    NSArray *timeMatches = [startRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    NSDate *startDate;
    
    if (timeRangeMatches.count) {
        NSTextCheckingResult *match = timeRangeMatches.lastObject;
        NSString *startHour = [string substringWithRange:[match rangeAtIndex:1]];
        NSString *startMinutes = [match rangeAtIndex:4].length ? [string substringWithRange:[match rangeAtIndex:4]] : @"00";
        NSString *startTime = [NSString stringWithFormat:@"%@ %@:%@", dateString, startHour, startMinutes];
        startDate = [dateTimeFormatter dateFromString:startTime];
    }
    else if (timeMatches.count) {
        NSTextCheckingResult *match = timeMatches.lastObject;
        NSString *startHour = [string substringWithRange:[match rangeAtIndex:1]];
        NSString *startMinutes = [string substringWithRange:[match rangeAtIndex:4]];
        NSString *startTime = [NSString stringWithFormat:@"%@ %@:%@", dateString, startHour, startMinutes];
        startDate = [dateTimeFormatter dateFromString:startTime];
    }
    
    return startDate;
}

- (NSDate *)endDateFromString:(NSString *)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [dateFormatter stringFromDate:self.date];
    
    NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
    dateTimeFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    
    NSError *regexError = nil;
    NSRegularExpression *startEndRegex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]{1,2})((\\:|\\.)([0-9]{1,2}))?(\\-)([0-9]{1,2})((\\:|\\.)([0-9]{1,2}))" options:NSRegularExpressionCaseInsensitive error:&regexError];
    if (regexError) {
        NSLog(@"Error: %@", regexError);
    }
    NSArray *timeRangeMatches = [startEndRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    NSDate *endDate;
    if (timeRangeMatches.count) {
        NSTextCheckingResult *match = timeRangeMatches.lastObject;
        NSString *endHour = [string substringWithRange:[match rangeAtIndex:6]];
        NSString *endMinutes = [string substringWithRange:[match rangeAtIndex:9]];
        NSString *endTime = [NSString stringWithFormat:@"%@ %@:%@", dateString, endHour, endMinutes];
        endDate = [dateTimeFormatter dateFromString:endTime];
    }
    
    return endDate;
}

- (NSString *)titleFromString:(NSString *)string
{
    NSError *regexError = nil;
    NSRegularExpression *startEndRegex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]{1,2})((\\:|\\.)([0-9]{1,2}))?(\\-)([0-9]{1,2})((\\:|\\.)([0-9]{1,2}))" options:NSRegularExpressionCaseInsensitive error:&regexError];
    NSRegularExpression *startRegex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]{1,2})((\\:|\\.)([0-9]{1,2}))" options:NSRegularExpressionCaseInsensitive error:&regexError];
    if (regexError) {
        NSLog(@"Error: %@", regexError);
    }
    
    NSArray *timeRangeMatches = [startEndRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    NSArray *timeMatches = [startRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    NSString *title = [string copy];
    
    if (timeRangeMatches.count) {
        NSTextCheckingResult *match = timeRangeMatches.lastObject;
        title = [string stringByReplacingCharactersInRange:match.range withString:@""];
    }
    else if (timeMatches.count) {
        NSTextCheckingResult *match = timeMatches.lastObject;
        title = [string stringByReplacingCharactersInRange:match.range withString:@""];
    }
    
    return title;
}

- (void)saveButtonPressed:(id)sender
{
    TextFieldTableViewCell *titleCell = (TextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *titleString = titleCell.textField.text;
    
    NSString *title = [self titleFromString:titleString];
    NSDate *startDate = [self startDateFromString:titleString];
    NSDate *endDate = [self endDateFromString:titleString];
    
    NSNumber *allDay = @NO;
    if (!startDate) {
        allDay = @YES;
        startDate = self.date;
    }
    if (!endDate) {
        endDate = [startDate dateByAddingTimeInterval:60*60];
    }

    TodoEvent *todoEvent = [[TodoEvent alloc] init];
    todoEvent.title = title;
    todoEvent.startDate = startDate;
    todoEvent.endDate = endDate;
    todoEvent.allDay = allDay.boolValue;
    
    [[TodoEventActions sharedActions] createTodoEvent:todoEvent];
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            cell.textField.placeholder = @"Buy groceries 10:00";
            break;
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
