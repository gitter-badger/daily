//
//  MissedEventsViewController.h
//  Daily
//
//  Created by Viktor Fröberg on 28/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MissedEventsViewController, TodoEventsCache;

@protocol MissedEventsViewControllerDelegate <NSObject>

@optional
- (void)missedEventsViewControllerDidFinish:(MissedEventsViewController *)missedEventsViewController;

@end

@interface MissedEventsViewController : UITableViewController

@property (nonatomic, weak) id <MissedEventsViewControllerDelegate> delegate;

- (void)setTodoEventsCache:(TodoEventsCache *)todoEventsCache;

@end
