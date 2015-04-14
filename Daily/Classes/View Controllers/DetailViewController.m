//
//  DetailViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 15/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "DetailViewController.h"
#import "TodoEvent.h"
#import "EKEventStore+VFDaily.h"
#import "NSDateFormatter+Extended.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface DetailViewController () <EKEventEditViewDelegate>

@property (nonatomic, strong) TodoEvent *editingTodoEvent;

@end

@implementation DetailViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.todoEvent.title;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed:)];
    if (self.todoEvent.allowsContentModifications) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editButtonPressed:)];
    }
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)closeButtonPressed:(id)sender
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)editButtonPressed:(id)sender
{
    EKEventEditViewController *editViewController = [[EKEventEditViewController alloc] init];
    editViewController.eventStore = [EKEventStore sharedEventStore];
    editViewController.event = self.todoEvent.event;
    self.editingTodoEvent = self.todoEvent;
    editViewController.editViewDelegate = self;
    [self presentViewController:editViewController animated:YES completion:nil];
}

#pragma mark - EKEventEditViewControllerDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    switch (action) {
        case EKEventEditViewActionCancelled:
            break;
            
        case EKEventEditViewActionSaved:
            if (self.editingTodoEvent) {
                NSArray *todoEvents = [TodoEvent todoEventsFromEvent:controller.event];
                [todoEvents enumerateObjectsUsingBlock:^(TodoEvent *todoEvent, NSUInteger idx, BOOL *stop) {
                    if ([self.editingTodoEvent.date isEqualToDate:todoEvent.date]) {
                        todoEvent.completed = self.editingTodoEvent.completed;
                        todoEvent.position = self.editingTodoEvent.position;
                    }
                }];
            }
            break;
            
        case EKEventEditViewActionDeleted:
            break;
            
        default:
            break;
    }
    self.editingTodoEvent = nil;

    // Make sure it only run once. Apple bug.
    controller.editViewDelegate = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }
    if (section == 1) {
        return 3;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"Move";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = self.todoEvent.title;
        cell.textLabel.font = [UIFont systemFontOfSize:22];
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        NSString *date = [[NSDateFormatter relativeDateFormatter] stringFromDate:self.todoEvent.startDate];
        cell.textLabel.text = date;
        cell.textLabel.font = [UIFont systemFontOfSize:18];
    }
    if (indexPath.section == 0 && indexPath.row == 2) {
        NSString *time = [NSString stringWithFormat:@"%@-%@", self.todoEvent.humanReadableStartTime, self.todoEvent.humanReadableEndTime];
        cell.textLabel.text = time;
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        cell.textLabel.text = @"Today";
    }
    if (indexPath.section == 1 && indexPath.row == 1) {
        cell.textLabel.text = @"Tomorrow";
    }
    if (indexPath.section == 1 && indexPath.row == 2) {
        cell.textLabel.text = @"Choose Date";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger daysBeforeNow = [[self.todoEvent.startDate startOfDay] daysBeforeDate:[[NSDate date] startOfDay]];
    EKEvent *event = self.todoEvent.event;
    
    if (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1)) {
        if (indexPath.row == 0) {
            event.startDate = [event.startDate dateByAddingDays:daysBeforeNow];
            event.endDate = [event.endDate dateByAddingDays:daysBeforeNow];
        }
        if (indexPath.row == 1) {
            event.startDate = [event.startDate dateByAddingDays:daysBeforeNow + 1];
            event.endDate = [event.endDate dateByAddingDays:daysBeforeNow + 1];
        }
        NSError *error;
        [[EKEventStore sharedEventStore] saveEvent:event span:EKSpanThisEvent error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
        }
        [self.tableView reloadData];
    }
    
//    if (indexPath.section == 1 && (indexPath.row == 2)) {
//        MonthDatePickerViewController *vc = [[MonthDatePickerViewController alloc] init];
//        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
//        [self presentViewController:nc animated:YES completion:nil];
//    }
}

@end
