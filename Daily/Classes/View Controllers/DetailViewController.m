//
//  DetailViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 15/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "TodoEventAPI.h"

// Models
#import "TodoEvent.h"
#import "TodoEventViewModel.h"
#import "DetailValue.h"

// Controllers
#import "DetailViewController.h"
#import "UIAlertController+DeleteTodoEvent.h"
#import "EditableTextViewController.h"

// Views
#import "DetailTableViewCell.h"

@interface DetailViewController () <EditableTextViewControllerDelegate>

@property (nonatomic, strong) TodoEvent *todoEvent;

@property (nonatomic, copy) NSString *editingKey;

@end

@implementation DetailViewController

- (instancetype)initWithTodoEvent:(TodoEvent *)todoEvent
{
    self = [super init];
    if (self) {
        self.todoEvent = todoEvent;
    }
    return self;
}

- (NSArray *)cellValues
{
    TodoEventViewModel *viewModel = [[TodoEventViewModel alloc] initWithTodoEvent:self.todoEvent];
    
    DetailValue *titleValue = [[DetailValue alloc] initWithKey:@"title" value:viewModel.titleText placeholder:@"Title" icon:[UIImage imageNamed:@"notes"]];
    
    DetailValue *timeValue = [[DetailValue alloc] initWithKey:@"time" value:viewModel.timeText placeholder:@"Time" icon:[UIImage imageNamed:@"clock"]];
    
    DetailValue *dateValue = [[DetailValue alloc] initWithKey:@"date" value:viewModel.dateText placeholder:@"Date" icon:[UIImage imageNamed:@"clock"]];
    
    DetailValue *locationValue = [[DetailValue alloc] initWithKey:@"location" value:viewModel.locationText placeholder:@"Location" icon:[UIImage imageNamed:@"location"]];
    
    DetailValue *urlValue = [[DetailValue alloc] initWithKey:@"url" value:viewModel.urlText placeholder:@"URL" icon:[UIImage imageNamed:@"url"]];
    
    DetailValue *notesValue = [[DetailValue alloc] initWithKey:@"notes" value:viewModel.notesText placeholder:@"Notes" icon:[UIImage imageNamed:@"notes"]];
    
    return @[titleValue, timeValue, dateValue, locationValue, urlValue, notesValue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *deleteEventButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete Event" style:UIBarButtonItemStylePlain target:self action:@selector(deleteEvent:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[flexibleSpace, deleteEventButton, flexibleSpace];
    self.navigationController.toolbarHidden = NO;
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed:)];
    
    [self.tableView registerClass:[DetailTableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)viewDidAppear:(BOOL)animated
{
//    [self.tableView reloadData];
}

- (void)deleteEvent:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTodoEvent:self.todoEvent handler:^(TodoEventSpan span) {
        
        switch (span) {
            case TodoEventSpanThis:
                [[TodoEventAPI sharedInstance] deleteThisTodoEvent:self.todoEvent completion:nil];
                break;
            case TodoEventSpanFuture:
                [[TodoEventAPI sharedInstance] deleteFutureTodoEvent:self.todoEvent completion:nil];
                break;
        }

        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)closeButtonPressed:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (UITableViewCell *)configureCell:(DetailTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    DetailValue *detailValue = [self.cellValues objectAtIndex:indexPath.row];
    [cell configureWithDetailValue:detailValue];
    return cell;
}

- (void)editableTextViewController:(EditableTextViewController *)controller didCompleteWithAction:(EditableTextViewAction)action
{
    if (action == EditableTextViewActionSaved) {
        TodoEvent *todoEvent = [self.todoEvent copy];
        [todoEvent setValue:controller.text forKey:self.editingKey];
        
        // optimistic update
        self.todoEvent = todoEvent;
        
        // pessimistic update
        [[TodoEventAPI sharedInstance] updateTodoEvent:todoEvent completion:nil];
    }
    
    self.editingKey = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailValue *detailValue = [self.cellValues objectAtIndex:indexPath.row];
    
    NSString *title = [NSString stringWithFormat:@"Edit %@", detailValue.placeholder];
    EditableTextViewController *vc = [[EditableTextViewController alloc] initWithTitle:title text:detailValue.value];
    vc.delegate = self;
    self.editingKey = detailValue.key;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
