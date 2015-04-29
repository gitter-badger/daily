//
//  MainViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 19/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "MainViewController.h"

#import "ListViewController.h"

#import "AddViewController.h"

#import "LSWeekView.h"

#import "FloatingButton.h"

#import "TodoEventAPI.h"

@interface MainViewController () <UIScrollViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) ListViewController *currentViewController;
@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) LSWeekView *weekView;
@property (nonatomic, strong) FloatingButton *addButton;

@property (nonatomic, getter=isLoaded) BOOL loaded;
@end

@implementation MainViewController

#pragma mark - Properties

- (NSArray *)items
{
    if (!_items) {
        _items = @[];
    }
    return _items;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarTappedAction:)
                                                 name:@"statusBarTappedNotification"
                                               object:nil];
    
    [self setupViews];
    
    NSDate *startDate = [[[NSDate date] dateBySubtractingDays:14] startOfDay];
    NSDate *endDate = [[[NSDate date] dateByAddingDays:14] endOfDay];
    
    RACSignal *fetchEventsSignal = [[[TodoEventAPI sharedInstance] rac_fetchTodoEventsWithStartDate:startDate
                                                                                           endDate:endDate] throttle:.2];
    [fetchEventsSignal subscribeNext:^(NSArray *items) {
        self.items = items;
        [self reloadDataAnimated:self.isLoaded];
        self.loaded = YES;
    }];
}

- (NSDate *)currentDate
{
    return self.currentViewController.date;
}

- (void)reloadDataAnimated:(BOOL)animated
{
    [self.pageViewController.viewControllers each:^(ListViewController *listViewController) {
        NSArray *items = [self itemsForDate:listViewController.date];
        [listViewController setItems:items animated:animated];
    }];
}

- (void)statusBarTappedAction:(NSNotification *)notification
{
    if (self.scrollView.contentOffset.y == 0) {
        NSDate *today = [NSDate date];
        [self.weekView setSelectedDate:today animated:YES];
        [self scrollToDate:today];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)scrollToDate:(NSDate *)date
{
    [self scrollToDate:date animated:YES];
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    if (![[self.currentDate startOfDay] isEqualToDate:[date startOfDay]]) {
        [self.currentViewController.tableView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) context:KVOContext];
        self.currentViewController.tableView.contentOffset = CGPointZero;
        
        ListViewController *viewController = [self listViewControllerWithDate:date];
        [viewController.tableView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial context:KVOContext];
        
        if ([self.currentDate isBeforeDate:date]) {
            [self.pageViewController setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:animated completion:nil];
        } else {
            [self.pageViewController setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionReverse animated:animated completion:nil];
        }
    
        self.currentViewController = viewController;
    }
}

- (void)setupViews
{
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.layer.cornerRadius = 5;

    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    
    self.weekView = [[LSWeekView alloc] init];
    __weak typeof(self)welf = self;
    self.weekView.didTapDateBlock = ^(NSDate *selectedDate) {
        [welf scrollToDate:selectedDate];
    };
    self.weekView.didChangeSelectedDateBlock = ^(NSDate *selectedDate) {
        [welf scrollToDate:selectedDate];
    };

    NSDictionary *options = @{ UIPageViewControllerOptionInterPageSpacingKey: @10 };
    self.pageViewController = [[UIPageViewController alloc]
                           initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                           navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                           options:options];

    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;

    self.currentViewController = [self listViewControllerWithDate:[NSDate date]];
    [self.currentViewController.tableView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionOld context:KVOContext];
    [self.pageViewController setViewControllers:@[self.currentViewController]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];

    [self.scrollView addSubview:self.weekView];

    [self addChildViewController:self.pageViewController];
    [self.scrollView addSubview:self.pageViewController.view];

    [self.view addSubview:self.scrollView];
    
    self.addButton = [[FloatingButton alloc] init];
    [self.addButton setTitle:@"+" forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addButton];
    
}

- (void)addButtonPressed:(id)sender
{
    AddViewController *avc = [[AddViewController alloc] initWithDate:self.currentDate];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:avc];
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.scrollView.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 20);

    self.weekView.frame = CGRectMake(0, self.scrollView.contentOffset.y, CGRectGetWidth(self.scrollView.frame), 100);
    
    CGSize contentSize = self.currentViewController.tableView.contentSize;
    CGSize defaultContentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame),
                                           CGRectGetHeight(self.scrollView.frame));
    if (contentSize.height < defaultContentSize.height) {
        contentSize.height = defaultContentSize.height;
    }
    self.pageViewController.view.frame = CGRectMake(0, CGRectGetHeight(self.weekView.frame), CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    
    if (self.scrollView.contentOffset.y > CGRectGetHeight(self.weekView.frame)) {
        self.scrollView.contentOffset = CGPointMake(0, CGRectGetHeight(self.weekView.frame));
    }
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), contentSize.height + CGRectGetHeight(self.weekView.frame));
    
    UIEdgeInsets edgeInset = UIEdgeInsetsMake(0, 20, 40, 0);
    CGSize size = CGSizeMake(50, 50);
    self.addButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - size.width - edgeInset.left,
                                      CGRectGetHeight(self.view.bounds) - size.height - edgeInset.bottom,
                                      size.width,
                                      size.height);
}

#pragma mark - KVO

static void *KVOContext = &KVOContext;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == KVOContext) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            UIScrollView *scrollView = object;
            CGSize oldContentSize = [change[NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = scrollView.contentSize;
            if (!CGSizeEqualToSize(newContentSize, oldContentSize)) {
                [self viewDidLayoutSubviews];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.weekView.frame = CGRectMake(0, scrollView.contentOffset.y, CGRectGetWidth(self.scrollView.frame), 100);
    
    CGRect frame = self.pageViewController.view.frame;
    CGPoint contentOffset = CGPointMake(0, CGRectGetHeight(self.weekView.frame));
    
    if (scrollView.contentOffset.y > CGRectGetHeight(self.weekView.frame)) {
        contentOffset.y = scrollView.contentOffset.y;
    }
    
    frame.origin.y = contentOffset.y;
    self.pageViewController.view.frame = frame;
    self.currentViewController.tableView.contentOffset = CGPointMake(0, contentOffset.y - CGRectGetHeight(self.weekView.frame));
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (targetContentOffset->y > CGRectGetHeight(self.weekView.frame))
        return;
    
    if (velocity.y > 0) {
        targetContentOffset->y = CGRectGetHeight(self.weekView.frame);
    }
    else if (velocity.y > 0) {
        targetContentOffset->y = 0;
    } else {
        if (targetContentOffset->y > (CGRectGetHeight(self.weekView.frame)/2)) {
            targetContentOffset->y = CGRectGetHeight(self.weekView.frame);
        } else {
            targetContentOffset->y = 0;
        }
    }
}

#pragma mark - UIPageViewControllerDataSource

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        [self.currentViewController.tableView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) context:KVOContext];
        self.currentViewController.tableView.contentOffset = CGPointZero;
        
        self.currentViewController = [pageViewController.viewControllers firstObject];
        [self.currentViewController.tableView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial context:KVOContext];
        
        [self.weekView setSelectedDate:self.currentDate animated:YES];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(ListViewController *)viewController
{
    NSDate *date = [viewController.date dateBySubtractingDays:1];
    return [self listViewControllerWithDate:date];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(ListViewController *)viewController
{
    NSDate *date = [viewController.date dateByAddingDays:1];
    return [self listViewControllerWithDate:date];
}

#pragma mark - Helpers

- (ListViewController *)listViewControllerWithDate:(NSDate *)date
{
    NSArray *items = [self itemsForDate:date];
    ListViewController *listViewController = [[ListViewController alloc] initWithDate:date items:items];
    return listViewController;
}

- (NSArray *)itemsForDate:(NSDate *)date
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date = %@", [date startOfDay]];
    return [self.items filteredArrayUsingPredicate:predicate];
}

@end
