//
//  DetailViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 15/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "TodoEventActions.h"
#import "TodoEventClient.h"

// Models
#import "MutableTodoEvent.h"
#import "TodoEventViewModel.h"

// Controllers
#import "DetailViewController.h"
#import "UIAlertController+DeleteTodoEvent.h"
#import "EditableTextViewController.h"

// Views
#import "DetailTableViewCell.h"

@interface DetailViewController ()

@property (nonatomic, strong) MutableTodoEvent *todoEvent;

@property (nonatomic, strong) NSArray *cellData;

@end

@implementation DetailViewController

- (instancetype)initWithTodoEvent:(MutableTodoEvent *)todoEvent
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.todoEvent = todoEvent;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.todoEvent.title;
    
    UIBarButtonItem *deleteEventButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete Event" style:UIBarButtonItemStylePlain target:self action:@selector(deleteEvent:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[flexibleSpace, deleteEventButton, flexibleSpace];
    self.navigationController.toolbarHidden = NO;
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed:)];
    
    TodoEventViewModel *viewModel = [[TodoEventViewModel alloc] initWithTodoEvent:self.todoEvent];
    
    NSMutableArray *cellData = [[NSMutableArray alloc] init];
    [cellData addObject:@{@"title": viewModel.titleText, @"placeholder": @"Title", @"image": [UIImage imageNamed:@"notes"]}];
    [cellData addObject:@{@"title": viewModel.timeText, @"placeholder": @"No time", @"image": [UIImage imageNamed:@"clock"]}];
    [cellData addObject:@{@"title": viewModel.dateText, @"placeholder": @"Date", @"image": [UIImage imageNamed:@"clock"]}];
    [cellData addObject:@{@"title": viewModel.locationText, @"placeholder": @"Location", @"image": [UIImage imageNamed:@"location"]}];
    [cellData addObject:@{@"title": viewModel.urlText, @"placeholder": @"URL", @"image": [UIImage imageNamed:@"url"]}];
    [cellData addObject:@{@"title": viewModel.notesText, @"placeholder": @"Notes", @"image": [UIImage imageNamed:@"notes"]}];
    
    self.cellData = [cellData copy];
    
    [self.tableView registerClass:[DetailTableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)deleteEvent:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTodoEvent:self.todoEvent handler:^(TodoEventSpan span) {
        
        switch (span) {
            case TodoEventSpanThis:
                [[TodoEventActions sharedActions] deleteThisTodoEvent:self.todoEvent];
                break;
            case TodoEventSpanFuture:
                [[TodoEventActions sharedActions] deleteFutureTodoEvent:self.todoEvent];
                break;
        }

        [self dismissViewController];
        
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)closeButtonPressed:(id)sender
{
    [self dismissViewController];
}

- (void)dismissViewController
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *cellData = [self.cellData objectAtIndex:indexPath.row];
    [cell setTitleText:[cellData objectForKey:@"title"] placeholderText:[cellData objectForKey:@"placeholder"] detailText:[cellData objectForKey:@"detail"] iconImage:[cellData objectForKey:@"image"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TodoEventViewModel *viewModel = [[TodoEventViewModel alloc] initWithTodoEvent:self.todoEvent];
    EditableTextViewController *vc;
    
    if (indexPath.row == 0) {
        vc = [[EditableTextViewController alloc] initWithTitle:@"Edit Title" text:viewModel.titleText completion:^(BOOL success, NSString *text) {
            self.todoEvent.title = text;
            [[TodoEventActions sharedActions] updateTodoEvent:self.todoEvent];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    if (indexPath.row == 3) {
        vc = [[EditableTextViewController alloc] initWithTitle:@"Edit Location" text:viewModel.locationText completion:^(BOOL success, NSString *text) {
            self.todoEvent.location = text;
            [[TodoEventActions sharedActions] updateTodoEvent:self.todoEvent];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    if (indexPath.row == 4) {
        vc = [[EditableTextViewController alloc] initWithTitle:@"Edit URL" text:viewModel.urlText completion:^(BOOL success, NSString *text) {
            self.todoEvent.url = text;
            [[TodoEventActions sharedActions] updateTodoEvent:self.todoEvent];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    if (indexPath.row == 5) {
        vc = [[EditableTextViewController alloc] initWithTitle:@"Edit Notes" text:viewModel.notesText completion:^(BOOL success, NSString *text) {
            self.todoEvent.notes = text;
            [[TodoEventActions sharedActions] updateTodoEvent:self.todoEvent];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
