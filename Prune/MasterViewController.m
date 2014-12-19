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

// Controllers
#import "MasterViewController.h"
#import "MissedEventsViewController.h"

// Views
#import "LSWeekView.h"
#import "HPReorderTableView.h"
#import "EventCell.h"

// Classes
#import "TodoEventsCache.h"

// Models
#import "TodoEvent.h"

// Categories
#import "NSDate+Utilities.h"
#import "NSDateFormatter+Extended.h"
#import "EKCalendar+VFDaily.h"
#import "EKEventStore+VFDaily.h"
#import "NSUserDefaults+DLY.h"


// Struct...
static NSInteger const kIncompletedSection = 0;
static NSInteger const kCompletedSection = 1;

@interface MasterViewController () <EKEventEditViewDelegate, EKEventViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, HPReorderTableViewDelegate, EKCalendarChooserDelegate, MissedEventsViewControllerDelegate>

@property (nonatomic, weak) IBOutlet HPReorderTableView *tableView;

@property (nonatomic, weak) IBOutlet UIButton *addButton;

@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *missedEventsButton;

@property (nonatomic, strong) LSWeekView *dayPicker;

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *currentDateLabel;

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) NSMutableArray *incompletedEvents;
@property (nonatomic, strong) NSMutableArray *completedEvents;

@property (nonatomic, strong) TodoEvent *editingTodoEvent;

@property (nonatomic) UIEdgeInsets tableViewEdgeInsets;

@property (nonatomic) CGPoint startContentOffset;
@property (nonatomic) CGPoint startOrigin;

@property (nonatomic, strong) UIView *checkImageView;
@property (nonatomic, strong) UIView *crossImageView;
@property (nonatomic, strong) UIView *dayPickerBackgroundView;
@property (nonatomic, strong) UIView *whiteBackgroundView;
@property (nonatomic, strong) UIView *shadowBottomView;

@property (nonatomic, strong) TodoEventsCache *todoEventsCache;

@end

@implementation MasterViewController

#pragma mark - Properties

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
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarTappedAction:)
                                                 name:@"statusBarTappedNotification"
                                               object:nil];
    
    self.checkImageView = [UIImageView imageViewWithImageName:@"check"];
    self.crossImageView = [UIImageView imageViewWithImageName:@"cross"];
    
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
        [[Analytics sharedAnalytics] track:@"Changed Week" properties:@{ @"Weeks From Now": [NSNumber numberWithInteger:weeksFromNow] }];
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
    
    self.missedEventsButton = [[UIButton alloc] init];
    self.missedEventsButton.backgroundColor = [UIColor colorWithRed:0.867 green:0.867 blue:0.867 alpha:1];
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
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.todoEventsCache = [[TodoEventsCache alloc] init];
    [self.todoEventsCache addObserver:self forKeyPath:NSStringFromSelector(@selector(todoEvents)) options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self setCurrentDateToTodayIfNeeded];
    [self fetchEvents];
}

- (void)applicationWillEnterForeground:(id)sender
{
    [self setCurrentDateToTodayIfNeeded];
    [self fetchEvents];
}

- (void)dealloc
{
    [self.todoEventsCache removeObserver:self forKeyPath:NSStringFromSelector(@selector(todoEvents))];
}

#pragma mark - UIViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLayoutSubviews
{
    self.dayPickerBackgroundView.frame = CGRectMake(0, 125-self.view.bounds.size.height, self.view.bounds.size.width, self.tableView.bounds.size.height);
    self.dayPicker.frame = CGRectMake(0, 0, self.view.frame.size.width, 80);
    
    self.titleView.frame = CGRectMake(0, 80, self.view.frame.size.width, 125);
    self.whiteBackgroundView.frame = CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height);
    self.titleLabel.frame = CGRectMake(0, 25, self.titleView.frame.size.width, 40);
    self.currentDateLabel.frame = CGRectMake(0, 60, self.titleView.frame.size.width, 40);
    
    self.missedEventsButton.frame = CGRectMake(15, 15, 28, 24);
    self.missedEventsButton.layer.cornerRadius = 5;
    
    self.settingsButton.frame = CGRectMake(self.titleView.frame.size.width-50, 0, 50, 50);
    self.shadowBottomView.frame = CGRectMake(self.tableViewEdgeInsets.left, self.titleView.frame.size.height - .5, self.titleView.frame.size.width - self.tableViewEdgeInsets.left - self.tableViewEdgeInsets.right, .5);
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:self.tableViewEdgeInsets];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:self.tableViewEdgeInsets];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(todoEvents))]) {
        if (self.todoEventsCache.countOfTodoEvents > 0) {
            [self.missedEventsButton setBackgroundColor:[UIColor redColor]];
        } else {
            [self.missedEventsButton setBackgroundColor:[UIColor colorWithRed:0.867 green:0.867 blue:0.867 alpha:1]];
        }
        [self.missedEventsButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)self.todoEventsCache.countOfTodoEvents] forState:UIControlStateNormal];
    }
}

#pragma mark - Actions

- (void)missedEventsButtonPressed:(id)sender
{
    MissedEventsViewController *vc = [[MissedEventsViewController alloc] init];
    vc.todoEventsCache = self.todoEventsCache;
    vc.delegate = self;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)settingsButtonPressed:(id)sender
{
    [[Analytics sharedAnalytics] track:@"Pressed Settings Button"];
    [self presentCalendarChooser];
}

- (void)addButtonPressed:(id)sender
{
    [[Analytics sharedAnalytics] track:@"Pressed Add Button"];
    [self presentAddEventControllerWithStartDate:self.currentDate];
}

- (void)statusBarTappedAction:(NSNotification *)notification
{
    if (self.tableView.contentOffset.y <= 0) {
        [[Analytics sharedAnalytics] track:@"Tapped Status Bar" properties:@{ @"top": @YES }];
        self.currentDate = [NSDate date];
        [self.dayPicker setSelectedDate:self.currentDate animated:YES];
        [self fetchEvents];
    } else {
        [[Analytics sharedAnalytics] track:@"Tapped Status Bar" properties:@{ @"top": @NO }];
    }
}

#pragma mark - EKEventViewControllerDelegate

- (void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EKEventEditViewControllerDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    switch (action) {
        case EKEventEditViewActionCancelled:
            break;
            
        case EKEventEditViewActionSaved:
            if (self.editingTodoEvent) {
                [[Analytics sharedAnalytics] track:@"Updated Event" properties:@{ @"Days Moved": [NSNumber numberWithInteger:[self.currentDate distanceInDaysToDate:controller.event.startDate]], @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:controller.event.startDate]] }];
                
                NSArray *todoEvents = [TodoEvent todoEventsFromEvent:controller.event];
                [todoEvents enumerateObjectsUsingBlock:^(TodoEvent *todoEvent, NSUInteger idx, BOOL *stop) {
                    if ([self.editingTodoEvent.date isEqualToDate:todoEvent.date]) {
                        todoEvent.completed = self.editingTodoEvent.completed;
                        todoEvent.position = self.editingTodoEvent.position;
                    }
                }];
            } else {
                [[Analytics sharedAnalytics] track:@"Created Event" properties:@{ @"All Day": [NSNumber numberWithBool:controller.event.allDay], @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:controller.event.startDate]] }];
            }
            break;
            
        case EKEventEditViewActionDeleted:
            [[Analytics sharedAnalytics] track:@"Deleted Event" properties:@{ @"swipe": @NO, @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:controller.event.startDate]] }];
            break;
            
        default:
            break;
    }
    self.editingTodoEvent = nil;
    // Make sure it only run once. Apple bug.
    controller.editViewDelegate = nil;
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
        [cell incompleteCell];
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
        if (todoEvent.hasFutureEvents) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"This is a repeating event." preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Delete This Event Only" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[EKEventStore sharedEventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                    if (granted) {
                        if ([todoEvent deleteThisEvent]) {
                            [[Analytics sharedAnalytics] track:@"Deleted Event" properties:@{ @"swipe": @YES, @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:todoEvent.startDate]] }];
                            if (indexPath.section == kIncompletedSection) {
                                [self.incompletedEvents removeObject:todoEvent];
                            } else if (indexPath.section == kCompletedSection) {
                                [self.completedEvents removeObject:todoEvent];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                            });
                        }
                    } else {
                        NSLog(@"Could't delete the event, access denied from the Calendar");
                    }
                }];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Delete All Future Events" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[EKEventStore sharedEventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                    if (granted) {
                        if ([todoEvent deleteFutureEvents]) {
                            [[Analytics sharedAnalytics] track:@"Deleted Event" properties:@{ @"swipe": @YES , @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:todoEvent.startDate]] }];
                            if (indexPath.section == kIncompletedSection) {
                                [self.incompletedEvents removeObject:todoEvent];
                            } else if (indexPath.section == kCompletedSection) {
                                [self.completedEvents removeObject:todoEvent];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                            });
                        }
                    } else {
                        NSLog(@"Couldn't delete the event, access denied from the Calendar");
                    }
                }];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Delete Event" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [[EKEventStore sharedEventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                    if (granted) {
                        if ([todoEvent deleteThisEvent]) {
                            [[Analytics sharedAnalytics] track:@"Deleted Event" properties:@{ @"swipe": @YES, @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:todoEvent.startDate]] }];
                            if (indexPath.section == kIncompletedSection) {
                                [self.incompletedEvents removeObject:todoEvent];
                            } else if (indexPath.section == kCompletedSection) {
                                [self.completedEvents removeObject:todoEvent];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                            });
                        }
                    } else {
                        NSLog(@"Couldn't delete the event, access denied from the Calendar");
                    }
                }];
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
    [[Analytics sharedAnalytics] track:@"Reordered Event" properties:@{ @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:todoEvent.startDate]] }];
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
    TodoEvent *todoEvent;
    if (indexPath.section == kIncompletedSection) {
        todoEvent = [self.incompletedEvents objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == kCompletedSection) {
        todoEvent = [self.completedEvents objectAtIndex:indexPath.row];
    }
    
    if (todoEvent.allowsContentModifications) {
        EKEventEditViewController *editViewController = [[EKEventEditViewController alloc] init];
        editViewController.eventStore = [EKEventStore sharedEventStore];
        editViewController.event = todoEvent.event;
        self.editingTodoEvent = todoEvent;
        editViewController.editViewDelegate = self;
        [self presentViewController:editViewController animated:YES completion:nil];
    }
    else {
        EKEventViewController *viewController = [[EKEventViewController alloc] init];
        viewController.event = todoEvent.event;
        viewController.delegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect dayPickerFrame = self.dayPicker.frame;
    dayPickerFrame.origin.y = scrollView.contentOffset.y;
    self.dayPicker.frame = dayPickerFrame;
}

#pragma mark - EKCalendarChooserDelegate

-(void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser
{
    [[Analytics sharedAnalytics] track:@"Changed Visible Calendars"];
    NSArray *calendars = [[EKEventStore sharedEventStore] calendarsForEntityType:EKEntityTypeEvent];
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
    [self dismissViewControllerAnimated:YES completion:^{
        [self fetchEvents];
    }];
}

#pragma mark - MissedEventsViewControllerDelegate

- (void)missedEventsViewControllerDidFinish:(MissedEventsViewController *)missedEventsViewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self fetchEvents];
    }];
}

#pragma mark - Private

- (void)presentAddEventControllerWithStartDate:(NSDate *)startDate
{
    [[EKEventStore sharedEventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                EKEventEditViewController *addViewController = [[EKEventEditViewController alloc] init];
                addViewController.eventStore = [EKEventStore sharedEventStore];
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

- (void)presentCalendarChooser
{
    [[EKEventStore sharedEventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            EKEventStore *eventStore = [EKEventStore sharedEventStore];
            NSArray *selectedCalendars = [EKCalendar selectedCalendarForEntityType:EKEntityTypeEvent];
            dispatch_async(dispatch_get_main_queue(), ^{
                EKCalendarChooser *calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple displayStyle:EKCalendarChooserDisplayAllCalendars entityType:EKEntityTypeEvent eventStore:eventStore];
                calendarChooser.showsDoneButton = YES;
                calendarChooser.showsCancelButton = YES;
                calendarChooser.delegate = self;
                calendarChooser.selectedCalendars = [NSSet setWithArray:selectedCalendars];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:calendarChooser];
                [self presentViewController:navigationController animated:YES completion:nil];
            });
        } else {
            NSLog(@"Access denied from Calendar");
        }
    }];
}

- (void)setCurrentDateToTodayIfNeeded
{
    NSDate *lastSeen = [[NSUserDefaults standardUserDefaults] lastSeen];
    CGFloat timeSinceClosed = -[lastSeen timeIntervalSinceNow];
    CGFloat minutes = 30.0;
    if (![self.currentDate isToday] && timeSinceClosed > (5 * minutes)) {
        self.currentDate = [NSDate date];
        [self.dayPicker setSelectedDate:self.currentDate animated:YES];
    }
}

- (void)fetchEvents
{
    NSDate *date = self.currentDate;
    self.titleLabel.text = [[[NSDateFormatter relativeWeekDayFormatterFromDate:date] stringFromDate:date] capitalizedString];
    self.currentDateLabel.text = [[[NSDateFormatter fullDateFormatter] stringFromDate:date] uppercaseString];
    
    [[EKEventStore sharedEventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSDate *startDate = self.currentDate;
                NSDate *endDate = self.currentDate;
                
                NSArray *events = [TodoEvent findAllWithStartDate:startDate endDate:endDate];
                
                [[Analytics sharedAnalytics] track:@"Changed Day" properties:@{ @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:date]], @"Number Of Events": [NSNumber numberWithInteger:events.count] }];
                
                NSPredicate *incompletedPredicate = [NSPredicate predicateWithFormat:@"completed = %@", @NO];
                self.incompletedEvents = [[events filteredArrayUsingPredicate:incompletedPredicate] mutableCopy];
                
                NSPredicate *completedPredicate = [NSPredicate predicateWithFormat:@"completed = %@", @YES];
                self.completedEvents = [[events filteredArrayUsingPredicate:completedPredicate] mutableCopy];
                
                [self.tableView reloadData];
                
                [self persistEventPositions];
                
                CGRect whiteBackgroundFrame = self.whiteBackgroundView.frame;
                whiteBackgroundFrame.size.height = self.tableView.bounds.size.height;
                self.whiteBackgroundView.frame = whiteBackgroundFrame;
                
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
        todoEvent.completed = @YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TodoEventWasCompleted" object:todoEvent];
        [[Analytics sharedAnalytics] track:@"Completed Event" properties:@{ @"swipe": @YES, @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:todoEvent.startDate]] }];
        [eventCell completeCell];
        [self.incompletedEvents removeObjectAtIndex:indexPath.row];
        [self.completedEvents insertObject:todoEvent atIndex:0];
        newIndexPath = [NSIndexPath indexPathForRow:[self.completedEvents indexOfObject:todoEvent] inSection:kCompletedSection];
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
    else if (indexPath.section == kCompletedSection) {
        [eventCell incompleteCell];
        todoEvent = [self.completedEvents objectAtIndex:indexPath.row];
        [[Analytics sharedAnalytics] track:@"Uncompleted Event" properties:@{ @"swipe": @YES, @"Days From Now": [NSNumber numberWithInteger:[[NSDate new] distanceInDaysToDate:todoEvent.startDate]] }];
        [self.completedEvents removeObjectAtIndex:indexPath.row];
        [self.incompletedEvents addObject:todoEvent];
        newIndexPath = [NSIndexPath indexPathForRow:[self.incompletedEvents indexOfObject:todoEvent] inSection:kIncompletedSection];
        todoEvent.completed = @NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TodoEventWasUncompleted" object:todoEvent];
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
    
    [self persistEventPositions];
}

- (void)persistEventPositions
{
    [self.incompletedEvents enumerateObjectsUsingBlock:^(TodoEvent *todoEvent, NSUInteger index, BOOL *stop) {
        todoEvent.position = [NSNumber numberWithInteger:index];
    }];
    [self.completedEvents enumerateObjectsUsingBlock:^(TodoEvent *todoEvent, NSUInteger index, BOOL *stop) {
        todoEvent.position = [NSNumber numberWithInteger:index];
    }];
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

@end
