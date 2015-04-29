//
//  AddViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 13/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "AddViewController.h"
#import "TextFieldTableViewCell.h"
#import "SZTextView.h"

#import "TodoEventAPI.h"
#import "TodoEvent.h"

@interface AddViewController () <UITextViewDelegate>

@property (nonatomic, copy, readonly) NSDate *date;

@property (nonatomic, strong) SZTextView *textView;

@end

@implementation AddViewController

#pragma mark - Lifecycle

- (instancetype)initWithDate:(NSDate *)date
{
    self = [super init];
    if (self) {
        _date = date;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Add item";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
    
    self.textView = [[SZTextView alloc] init];
    self.textView.placeholder = @"Buy groceries 10:00";
    self.textView.returnKeyType = UIReturnKeyDone;
    self.textView.delegate = self;
    self.textView.editable = YES;
    self.textView.font = [UIFont systemFontOfSize:18];

    [self.view setSubviews:@[ self.textView ]];
}

- (void)viewDidLayoutSubviews
{
    self.textView.frame = self.view.bounds;
    self.textView.textContainerInset = UIEdgeInsetsMake(20, 10, 20, 10);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.textView resignFirstResponder];
    
    [super viewWillDisappear:animated];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)cancelButtonPressed:(id)sender
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveButtonPressed:(id)sender
{
    NSString *titleString = self.textView.text;
    
    NSString *title = [self titleFromString:titleString];
    NSDate *startDate = [self startDateFromString:titleString];
    NSDate *endDate = [self endDateFromString:titleString];
    
    BOOL allDay = NO;
    if (!startDate) {
        allDay = YES;
        startDate = self.date;
    }
    if (!endDate) {
        endDate = [startDate dateByAddingTimeInterval:60*60];
    }
    
    [[TodoEventAPI sharedInstance] createTodoEventWithTitle:title startDate:startDate endDate:endDate allDay:allDay completion:^(NSError *error, TodoEvent *todoEvent) {
        if (error) NSLog(@"Error: %@", error);
    }];
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

@end
