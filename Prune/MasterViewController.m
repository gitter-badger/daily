//
//  MasterViewController.m
//  Prune
//
//  Created by Viktor Fröberg on 15/08/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

// Frameworks
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

// Analytics
#import "DAYAnalytics.h"

// Controllers
#import "MasterViewController.h"
#import "MissedEventsViewController.h"

// Views
#import "LSWeekView.h"
#import "HPReorderTableView.h"
#import "EventCell.h"

// Stores
#import "SettingsStore.h"
#import "TodoEventStore.h"

// Service
#import "NotificationService.h"

// Models
#import "TodoEvent.h"

// Categories
#import "NSDate+Utilities.h"
#import "NSDateFormatter+Extended.h"

static NSString * const kStatusBarTappedNotification = @"statusBarTappedNotification";
static NSString * const kLastClosedDate = @"lastClosedDate";

// Struct...
static NSInteger const kIncompletedSection = 0;
static NSInteger const kCompletedSection = 1;

@interface MasterViewController () <EKEventEditViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, HPReorderTableViewDelegate, EKCalendarChooserDelegate>

@property (nonatomic, weak) IBOutlet HPReorderTableView *tableView;

@property (nonatomic, weak) IBOutlet UIButton *addButton;

@property (nonatomic, strong) UIButton *todayButton;
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *missedEventsButton;

@property (nonatomic, strong) LSWeekView *dayPicker;

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *currentDateLabel;

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) NSMutableArray *incompletedEvents;
@property (nonatomic, strong) NSMutableArray *completedEvents;
@property (nonatomic, strong) NSMutableArray *missedEvents;

@property (nonatomic, strong) TodoEvent *editingTodoEvent;

@property (nonatomic) UIEdgeInsets tableViewEdgeInsets;

@property (nonatomic) CGPoint startContentOffset;
@property (nonatomic) CGPoint startOrigin;

@property (nonatomic, strong) UIView *checkImageView;
@property (nonatomic, strong) UIView *crossImageView;
@property (nonatomic, strong) UIView *dayPickerBackgroundView;
@property (nonatomic, strong) UIView *whiteBackgroundView;
@property (nonatomic, strong) UIView *shadowBottomView;

@end

@implementation MasterViewController

- (NSDate *)currentDate
{
    NSDate *currentDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentDate"];
    if (!currentDate) {
        currentDate = [NSDate date];
    }
    return currentDate;
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:@"currentDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidBecomeActive:(id)sender
{
    [self setCurrentDateToTodayIfNeeded];
    [self fetchEvents];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarTappedAction:)
                                                 name:kStatusBarTappedNotification
                                               object:nil];
    
    self.checkImageView = [self viewWithImageName:@"check"];
    self.crossImageView = [self viewWithImageName:@"cross"];
    
    self.addButton.layer.cornerRadius = 25;
    self.addButton.backgroundColor = [UIColor redColor];
    [self.addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableViewEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.layer.cornerRadius = 5;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    
    self.dayPickerBackgroundView = [[UIView alloc] init];
    [self.dayPickerBackgroundView setBackgroundColor:[UIColor blackColor]];
    
    self.dayPicker = [[LSWeekView alloc] init];
    self.dayPicker.backgroundColor = [UIColor blackColor];
    self.dayPicker.labelTextColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.3];
    self.dayPicker.selectedDayTextColor = [UIColor blackColor];
    self.dayPicker.selectedDayBackgroundColor = [UIColor whiteColor];
    self.dayPicker.dayTextColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.8];
    self.dayPicker.todaySelectedBackgroundColor = [UIColor redColor];
    self.dayPicker.todaySelectedTextColor = [UIColor whiteColor];
    self.dayPicker.todayTextColor = [UIColor redColor];
    self.dayPicker.selectedDate = self.currentDate;
    __weak typeof(self) weakSelf = self;
    self.dayPicker.didChangeSelectedDateBlock = ^(NSDate *selectedDate)
    {
        weakSelf.tableView.contentOffset = CGPointMake(0, 0);
        weakSelf.currentDate = selectedDate;
        NSInteger weeksFromNow = ceil([[NSDate date] distanceInDaysToDate:selectedDate] / 7);
        [[DAYAnalytics sharedAnalytics] track:@"Changed Week" properties:@{ @"Weeks From Now": [NSNumber numberWithInteger:weeksFromNow] }];
        [weakSelf fetchEvents];
    };
    self.dayPicker.didTapDateBlock = ^(NSDate *selectedDate)
    {
        weakSelf.tableView.contentOffset = CGPointMake(0, 0);
        weakSelf.currentDate = selectedDate;
        [weakSelf fetchEvents];
    };
    
    self.titleView = [[UIView alloc] init];
    self.titleView.backgroundColor = [UIColor clearColor];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"";
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleView addSubview:self.titleLabel];
    
    self.currentDateLabel = [[UILabel alloc] init];
    self.currentDateLabel.text = @"";
    self.currentDateLabel.textColor = [UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1];
    self.currentDateLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:14];
    self.currentDateLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleView addSubview:self.currentDateLabel];
    
    self.todayButton = [[UIButton alloc] init];
    [self.todayButton setImage:[UIImage imageNamed:@"back-button"] forState:UIControlStateNormal];
    [self.todayButton addTarget:self action:@selector(todayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:self.todayButton];
    
    self.missedEventsButton = [[UIButton alloc] init];
    self.missedEventsButton.backgroundColor = [UIColor redColor];
    self.missedEventsButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    [self.missedEventsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.missedEventsButton addTarget:self action:@selector(missedEventsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:self.missedEventsButton];
    
    self.settingsButton = [[UIButton alloc] init];
    [self.settingsButton setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:self.settingsButton];
    
    self.shadowBottomView = [[UIView alloc] init];
    self.shadowBottomView.backgroundColor = self.tableView.separatorColor;
    [self.titleView addSubview:self.shadowBottomView];
    
    self.whiteBackgroundView = [[UIView alloc] init];
    self.whiteBackgroundView.backgroundColor = [UIColor whiteColor];
    self.whiteBackgroundView.layer.cornerRadius = 5;
    
    [self.tableView addSubview:self.whiteBackgroundView];
    [self.tableView addSubview:self.dayPickerBackgroundView];
    [self.tableView addSubview:self.dayPicker];
    [self.tableView addSubview:self.titleView];
    
    [self.tableView sendSubviewToBack:self.whiteBackgroundView];
    [self.tableView sendSubviewToBack:self.dayPicker];
    [self.tableView sendSubviewToBack:self.dayPickerBackgroundView];
    
    
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 205);
    headerView.backgroundColor = [UIColor clearColor];
    headerView.userInteractionEnabled = NO;

    self.tableView.tableHeaderView = headerView;
    
    [self setCurrentDateToTodayIfNeeded];
    [self fetchEvents];
    [self fetchMissedEvents];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)fetchMissedEvents
{
    [[TodoEventStore sharedTodoEventStore].eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSDate *dateMonthAgo = [NSDate dateWithDaysBeforeNow:30];
            NSDate *firstLaunch = [NSDate dateWithDaysBeforeNow:2];
            if ([dateMonthAgo isEarlierThanDate:firstLaunch]) {
                dateMonthAgo = firstLaunch;
            }
            NSDate *dateOfToday = [NSDate date];
            NSLog(@"%@", dateOfToday);
            
            NSArray *todoEvents = [[TodoEventStore sharedTodoEventStore] incompletedTodoEventsWithStartDate:dateMonthAgo endDate:dateOfToday];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.missedEvents = [todoEvents mutableCopy];
                [self.missedEventsButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)todoEvents.count] forState:UIControlStateNormal];
            });
        } else {
            NSLog(@"Access denied from Calendar");
        }
    }];
}

- (void)setCurrentDateToTodayIfNeeded
{
    NSDate *lastClosed = [[NSUserDefaults standardUserDefaults] objectForKey:kLastClosedDate];
    CGFloat timeSinceClosed = -[lastClosed timeIntervalSinceNow];
    CGFloat minutes = 60.0;
    if (![self.currentDate isToday] && timeSinceClosed > (5 * minutes)) {
        self.currentDate = [NSDate date];
        [self.dayPicker setSelectedDate:self.currentDate animated:YES];
    }
}

-(void)viewDidLayoutSubviews
{
    self.dayPickerBackgroundView.frame = CGRectMake(0, 125-self.view.bounds.size.height, self.view.bounds.size.width, self.tableView.bounds.size.height);
    self.dayPicker.frame = CGRectMake(0, 0, self.view.frame.size.width, 80);
    
    self.titleView.frame = CGRectMake(0, 80, self.view.frame.size.width, 125);
    self.whiteBackgroundView.frame = CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height);
    self.titleLabel.frame = CGRectMake(0, 25, self.titleView.frame.size.width, 40);
    self.currentDateLabel.frame = CGRectMake(0, 60, self.titleView.frame.size.width, 40);
//    self.todayButton.frame = CGRectMake(0, 0, 40, 50);
    
    self.missedEventsButton.frame = CGRectMake(15, 15, 26, 26);
    self.missedEventsButton.layer.cornerRadius = 13;
    
    self.settingsButton.frame = CGRectMake(self.titleView.frame.size.width-50, 0, 50, 50);
    self.shadowBottomView.frame = CGRectMake(self.tableViewEdgeInsets.left, self.titleView.frame.size.height - .5, self.titleView.frame.size.width - self.tableViewEdgeInsets.left - self.tableViewEdgeInsets.right, .5);
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:self.tableViewEdgeInsets];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:self.tableViewEdgeInsets];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIView *)viewWithImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

- (void)fetchEvents
{
    NSDate *date = self.currentDate;
    self.titleLabel.text = [[[NSDateFormatter relativeWeekDayFormatterFromDate:date] stringFromDate:date]capitalizedString];
    self.currentDateLabel.text = [[[NSDateFormatter fullDateFormatter] stringFromDate:date] uppercaseString];
    
    if ([self.currentDate isLaterThanDate:[NSDate date]]) {
        [self.todayButton setImage:[UIImage imageNamed:@"back-button"] forState:UIControlStateNormal];
        self.todayButton.hidden = NO;
    }
    else if ([[self.currentDate dateAtEndOfDay] isEarlierThanDate:[NSDate date]]) {
        [self.todayButton setImage:[UIImage imageNamed:@"forward-button"] forState:UIControlStateNormal];
        self.todayButton.hidden = NO;
    }
    else {
        self.todayButton.hidden = YES;
    }
    
    [[TodoEventStore sharedTodoEventStore].eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            self.incompletedEvents = [NSMutableArray array];
            self.completedEvents = [NSMutableArray array];
            
            NSArray *calendars = [[SettingsStore sharedSettingsStore] calendars];
            if (calendars.count) {
                NSArray *events = [[TodoEventStore sharedTodoEventStore] todoEventsFromDate:date calendars:calendars];
                
                [[DAYAnalytics sharedAnalytics] track:@"Changed Day" properties:@{ @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:date]], @"Number Of Events": [NSNumber numberWithInteger:events.count] }];
                
                NSPredicate *incompletedPredicate = [NSPredicate predicateWithFormat:@"completed = %@", @NO];
                self.incompletedEvents = [[events filteredArrayUsingPredicate:incompletedPredicate] mutableCopy];
                
                NSPredicate *completedPredicate = [NSPredicate predicateWithFormat:@"completed = %@", @YES];
                self.completedEvents = [[events filteredArrayUsingPredicate:completedPredicate] mutableCopy];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
                
                CGRect whiteBackgroundFrame = self.whiteBackgroundView.frame;
                whiteBackgroundFrame.size.height = self.tableView.bounds.size.height;
                self.whiteBackgroundView.frame = whiteBackgroundFrame;
                
                [self persistEventPositions];
            
                self.titleLabel.text = [[NSDateFormatter relativeWeekDayFormatterFromDate:date] stringFromDate:date];
                self.currentDateLabel.text = [[[NSDateFormatter fullDateFormatter] stringFromDate:date] uppercaseString];
            });
        } else {
            NSLog(@"Access denied from Calendar");
        }
    }];
}

- (void)toggleCompletionForCell:(UITableViewCell *)cell
{
    EventCell *eventCell = (EventCell *)cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    TodoEvent *todoEvent;
    NSIndexPath *newIndexPath;
    if (indexPath.section == kIncompletedSection) {
        todoEvent = [self.incompletedEvents objectAtIndex:indexPath.row];
        [todoEvent setCompleted:@YES];
        [[DAYAnalytics sharedAnalytics] track:@"Completed Event" properties:@{ @"swipe": @YES, @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:todoEvent.startDate]] }];
        [eventCell completeCell];
        [self.incompletedEvents removeObjectAtIndex:indexPath.row];
        [self.completedEvents insertObject:todoEvent atIndex:0];
        newIndexPath = [NSIndexPath indexPathForRow:[self.completedEvents indexOfObject:todoEvent] inSection:kCompletedSection];
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
    else if (indexPath.section == kCompletedSection) {
        [eventCell incompleteCell];
        todoEvent = [self.completedEvents objectAtIndex:indexPath.row];
        [[DAYAnalytics sharedAnalytics] track:@"Uncompleted Event" properties:@{ @"swipe": @YES, @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:todoEvent.startDate]] }];
        [self.completedEvents removeObjectAtIndex:indexPath.row];
        [self.incompletedEvents addObject:todoEvent];
        newIndexPath = [NSIndexPath indexPathForRow:[self.incompletedEvents indexOfObject:todoEvent] inSection:kIncompletedSection];
        [todoEvent setCompleted:@NO];
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
    
    [self persistEventPositions];
}

- (void)persistEventPositions
{
    [self.incompletedEvents enumerateObjectsUsingBlock:^(TodoEvent *todoEvent, NSUInteger index, BOOL *stop) {
        [todoEvent setPosition:[NSNumber numberWithInteger:index]];
    }];
    [self.completedEvents enumerateObjectsUsingBlock:^(TodoEvent *todoEvent, NSUInteger index, BOOL *stop) {
        [todoEvent setPosition:[NSNumber numberWithInteger:index]];
    }];
}

- (void)missedEventsButtonPressed:(id)sender
{
    MissedEventsViewController *vc = [[MissedEventsViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.events = self.missedEvents;
    [self presentViewController:nc animated:YES completion:nil];
    // Proceed to an other view controller.
}

- (void)todayButtonPressed:(id)sender
{
    [[DAYAnalytics sharedAnalytics] track:@"Pressed Today Button"];
    self.currentDate = [NSDate date];
    [self.dayPicker setSelectedDate:self.currentDate animated:YES];
    [self fetchEvents];
}

- (void)settingsButtonPressed:(id)sender
{
    [[DAYAnalytics sharedAnalytics] track:@"Pressed Settings Button"];
    [self presentCalendarChooser];
}

- (void)addButtonPressed:(id)sender
{
    [[DAYAnalytics sharedAnalytics] track:@"Pressed Add Button"];
    [self presentAddEventControllerWithStartDate:self.currentDate];
}

- (void)presentCalendarChooser
{
    [[TodoEventStore sharedTodoEventStore].eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                EKCalendarChooser *calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple displayStyle:EKCalendarChooserDisplayAllCalendars entityType:EKEntityTypeEvent eventStore:[TodoEventStore sharedTodoEventStore].eventStore];
                calendarChooser.showsDoneButton = YES;
                calendarChooser.showsCancelButton = YES;
                calendarChooser.delegate = self;
                calendarChooser.selectedCalendars = [NSSet setWithArray:[[SettingsStore sharedSettingsStore] calendars]];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:calendarChooser];
                [self presentViewController:navigationController animated:YES completion:nil];
            });
        } else {
            NSLog(@"Access denied from Calendar");
        }
    }];
}

- (void)presentAddEventControllerWithStartDate:(NSDate *)startDate
{
    [[TodoEventStore sharedTodoEventStore].eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                EKEventEditViewController *addViewController = [[EKEventEditViewController alloc] init];
                addViewController.eventStore = [TodoEventStore sharedTodoEventStore].eventStore;
                addViewController.editViewDelegate = self;
                addViewController.event.timeZone = [NSTimeZone defaultTimeZone];
                addViewController.event.allDay = YES;
                addViewController.event.startDate = startDate;
                addViewController.event.endDate = self.currentDate;
                [self presentViewController:addViewController animated:YES completion:nil];
            });
        } else {
            NSLog(@"Access denied from Calendar");
        }
    }];
}

#pragma mark - EKEventViewControllerDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    switch (action) {
        case EKEventEditViewActionCancelled:
            break;
            
        case EKEventEditViewActionSaved:
            if (self.editingTodoEvent) {
                [[DAYAnalytics sharedAnalytics] track:@"Updated Event" properties:@{ @"Days Moved": [NSNumber numberWithInteger:[self.currentDate distanceInDaysToDate:controller.event.startDate]], @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:controller.event.startDate]] }];
                TodoEvent *todoEvent = [[TodoEventStore sharedTodoEventStore] todoEventFromEvent:controller.event day:self.currentDate];
                todoEvent.completed = self.editingTodoEvent.completed;
                todoEvent.position = self.editingTodoEvent.position;
            } else {
                [[DAYAnalytics sharedAnalytics] track:@"Created Event" properties:@{ @"All Day": [NSNumber numberWithBool:controller.event.allDay], @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:controller.event.startDate]] }];
            }
            break;
            
        case EKEventEditViewActionDeleted:
            [[DAYAnalytics sharedAnalytics] track:@"Deleted Event" properties:@{ @"swipe": @NO, @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:controller.event.startDate]] }];
            break;
            
        default:
            break;
    }
    self.editingTodoEvent = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        if (action == EKEventEditViewActionSaved || action == EKEventEditViewActionDeleted) {
            [self fetchEvents];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kIncompletedSection) {
        return self.incompletedEvents.count;
    }
    else if (section == kCompletedSection) {
        return self.completedEvents.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    TodoEvent *todoEvent;
    NSInteger section = indexPath.section;
    if (section == kIncompletedSection) {
        todoEvent = [self.incompletedEvents objectAtIndex:indexPath.row];
    }
    else if (section == kCompletedSection) {
        todoEvent = [self.completedEvents objectAtIndex:indexPath.row];
    }
    
    NSString *time = @"";
    if ([todoEvent.startDate isEqualToDateIgnoringTime:self.currentDate]) {
        time = todoEvent.humanReadableStartTime;
    } else if ([todoEvent.endDate isEqualToDateIgnoringTime:self.currentDate]) {
        time = todoEvent.humanReadableEndTime;
    } else {
        if (!todoEvent.allDay) {
            time = @"All day";
        }
    }
    cell = [cell setTitle:todoEvent.title time:time location:todoEvent.location];
    
    if (section == kIncompletedSection) {
        if ([todoEvent.endDate isEarlierThanDate:[self.currentDate dateAtStartOfDay]]) {
            [cell missedCell];
        } else {
            [cell incompleteCell];
        }
    } else if (section == kCompletedSection) {
        [cell completeCell];
    }
    
    cell.selectedBackgroundView = [[UIView alloc] init];
    
    UIView *checkView = self.checkImageView;
    UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
    
    UIView *crossView = self.crossImageView;
    UIColor *redColor = [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];
    
    cell.firstTrigger = 0.20;
    cell.secondTrigger = 0.70;
    
    [cell setDefaultColor:[UIColor lightGrayColor]];
    
    [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [self toggleCompletionForCell:cell];
    }];
    
    [cell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        TodoEvent *todoEvent;
        if (indexPath.section == kIncompletedSection) {
            todoEvent = [self.incompletedEvents objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == kCompletedSection) {
            todoEvent = [self.completedEvents objectAtIndex:indexPath.row];
        }
        if (todoEvent.event.recurrenceRules.count) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"This is a repeating event." preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Delete This Event Only" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[TodoEventStore sharedTodoEventStore].eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                    if (granted) {
                        [[TodoEventStore sharedTodoEventStore].eventStore removeEvent:todoEvent.event span:EKSpanThisEvent commit:YES error:nil];
                        [[DAYAnalytics sharedAnalytics] track:@"Deleted Event" properties:@{ @"swipe": @YES, @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:todoEvent.startDate]] }];
                    } else {
                        NSLog(@"Could't delete the event, access denied from the Calendar");
                    }
                }];
                if (indexPath.section == kIncompletedSection) {
                    [self.incompletedEvents removeObject:todoEvent];
                } else if (indexPath.section == kCompletedSection) {
                    [self.completedEvents removeObject:todoEvent];
                }
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Delete All Future Events" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[TodoEventStore sharedTodoEventStore].eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                    if (granted) {
                        [[TodoEventStore sharedTodoEventStore].eventStore removeEvent:todoEvent.event span:EKSpanFutureEvents commit:YES error:nil];
                        [[DAYAnalytics sharedAnalytics] track:@"Deleted Event" properties:@{ @"swipe": @YES , @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:todoEvent.startDate]] }];
                    } else {
                        NSLog(@"Couldn't delete the event, access denied from the Calendar");
                    }
                }];
                if (indexPath.section == kIncompletedSection) {
                    [self.incompletedEvents removeObject:todoEvent];
                } else if (indexPath.section == kCompletedSection) {
                    [self.completedEvents removeObject:todoEvent];
                }
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Delete Event" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [[TodoEventStore sharedTodoEventStore].eventStore removeEvent:todoEvent.event span:EKSpanThisEvent commit:YES error:nil];
                [[DAYAnalytics sharedAnalytics] track:@"Deleted Event" properties:@{ @"swipe": @YES, @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:todoEvent.startDate]] }];
                if (indexPath.section == kIncompletedSection) {
                    [self.incompletedEvents removeObject:todoEvent];
                } else if (indexPath.section == kCompletedSection) {
                    [self.completedEvents removeObject:todoEvent];
                }
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    TodoEvent *todoEvent;
    if (fromIndexPath.section == kIncompletedSection) {
        todoEvent = [self.incompletedEvents objectAtIndex:fromIndexPath.row];
        [self.incompletedEvents removeObjectAtIndex:fromIndexPath.row];
        [self.incompletedEvents insertObject:todoEvent atIndex:toIndexPath.row];
        [self persistEventPositions];
    }
    else if (fromIndexPath.section == kCompletedSection) {
        todoEvent = [self.completedEvents objectAtIndex:fromIndexPath.row];
        [self.completedEvents removeObjectAtIndex:fromIndexPath.row];
        [self.completedEvents insertObject:todoEvent atIndex:toIndexPath.row];
        [self persistEventPositions];
    }
    [[DAYAnalytics sharedAnalytics] track:@"Reordered Event" properties:@{ @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:todoEvent.startDate]] }];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:self.tableViewEdgeInsets];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:self.tableViewEdgeInsets];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        if (sourceIndexPath.section == kIncompletedSection) {
            return [NSIndexPath indexPathForRow:self.incompletedEvents.count-1 inSection:sourceIndexPath.section];
        }
        else if (sourceIndexPath.section == kCompletedSection) {
            return [NSIndexPath indexPathForRow:0 inSection:sourceIndexPath.section];
        }
    }
    return proposedDestinationIndexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TodoEvent *todoEvent;
    if (indexPath.section == kIncompletedSection) {
        todoEvent = [self.incompletedEvents objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == kCompletedSection) {
        todoEvent = [self.completedEvents objectAtIndex:indexPath.row];
    }
    
    
    if (!todoEvent.allDay) {
        return 80;
    }
    else if (todoEvent.location.length) {
        return 80;
    }
    else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EKEventEditViewController *editViewController = [[EKEventEditViewController alloc] init];
    editViewController.eventStore = [TodoEventStore sharedTodoEventStore].eventStore;
    TodoEvent *todoEvent;
    if (indexPath.section == kIncompletedSection) {
        todoEvent = [self.incompletedEvents objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == kCompletedSection) {
        todoEvent = [self.completedEvents objectAtIndex:indexPath.row];
    }
    editViewController.event = todoEvent.event;
    self.editingTodoEvent = todoEvent;
    editViewController.editViewDelegate = self;
    [self presentViewController:editViewController animated:YES completion:nil];
}

#pragma mark - Status Bar

- (void)statusBarTappedAction:(NSNotification *)notification
{
    if (self.tableView.contentOffset.y <= 0) {
        [[DAYAnalytics sharedAnalytics] track:@"Tapped Status Bar" properties:@{ @"top": @YES }];
        self.currentDate = [NSDate date];
        [self.dayPicker setSelectedDate:self.currentDate animated:YES];
        [self fetchEvents];
    } else {
        [[DAYAnalytics sharedAnalytics] track:@"Tapped Status Bar" properties:@{ @"top": @NO }];
    }
}

#pragma mark - Scroll View

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect dayPickerFrame = self.dayPicker.frame;
    dayPickerFrame.origin.y = scrollView.contentOffset.y;
    self.dayPicker.frame = dayPickerFrame;
}

#pragma mark - Calendar Picker

-(void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser
{
    [[DAYAnalytics sharedAnalytics] track:@"Changed Visible Calendars"];
    NSSet *calendars = calendarChooser.selectedCalendars;
    if (calendars && calendars.count) {
        [[SettingsStore sharedSettingsStore] setCalendars:[calendars allObjects]];
    } else {
        [[SettingsStore sharedSettingsStore] setCalendars:[NSArray array]];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self fetchEvents];
    }];
}

@end
