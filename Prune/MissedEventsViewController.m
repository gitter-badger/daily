//
//  MissedEventsViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 28/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "MissedEventsViewController.h"

#import "TodoEvent.h"

@interface MissedEventsViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation MissedEventsViewController

- (void)viewDidLoad
{
    self.title = @"Missed events";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed:)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)closeButtonPressed:(id)sender
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    TodoEvent *todoEvent = [self.events objectAtIndex:indexPath.row];
    
    cell.textLabel.text = todoEvent.title;
    
    return cell;
}

@end
