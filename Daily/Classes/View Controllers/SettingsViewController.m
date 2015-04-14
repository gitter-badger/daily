//
//  SettingsViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 15/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "SettingsViewController.h"

#import "EKCalendar+VFDaily.h"

@interface SettingsViewController () <EKCalendarChooserDelegate>

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Settings";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed:)];
    self.tableView.layer.cornerRadius = 5;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)doneButtonPressed:(id)sender
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"List";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = @"Calendars";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.section == 0 &&indexPath.row == 1) {
        cell.textLabel.text = @"Show End Times";
        BOOL showEndTimes = [[NSUserDefaults standardUserDefaults] boolForKey:@"showEndTimes"];
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchView.on = showEndTimes;
        [switchView addTarget:self action:@selector(didToggleShowEndTimes:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView;
    }
    
    return cell;
}

- (void)didToggleShowEndTimes:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"showEndTimes"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self presentCalendarChooser];
    }
}


#pragma mark - ???

- (void)presentCalendarChooser
{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    NSArray *selectedCalendars = [EKCalendar selectedCalendarForEntityType:EKEntityTypeEvent];
    dispatch_async(dispatch_get_main_queue(), ^{
        EKCalendarChooser *calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple displayStyle:EKCalendarChooserDisplayAllCalendars entityType:EKEntityTypeEvent eventStore:eventStore];
        calendarChooser.showsDoneButton = YES;
        calendarChooser.showsCancelButton = YES;
        calendarChooser.delegate = self;
        calendarChooser.selectedCalendars = [NSSet setWithArray:selectedCalendars];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:calendarChooser];
        [self presentViewController:nc animated:YES completion:nil];
    });
}


#pragma mark - EKCalendarChooserDelegate

-(void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser
{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    NSArray *calendars = [eventStore calendarsForEntityType:EKEntityTypeEvent];
    NSArray *selectedCalendars = [calendarChooser.selectedCalendars allObjects];
    [calendars enumerateObjectsUsingBlock:^(EKCalendar *calendar, NSUInteger idx, BOOL *stop) {
        if ([selectedCalendars containsObject:calendar]) {
            if (!calendar.enabledDate) {
                calendar.enabledDate = [NSDate date];
            }
        }
        else {
            calendar.enabledDate = nil;
        }
    }];
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
