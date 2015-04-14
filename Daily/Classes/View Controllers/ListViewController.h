//
//  ListViewController.h
//  Daily
//
//  Created by Viktor Fröberg on 20/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UITableViewController

@property (nonatomic, strong, readonly) NSDate *date;

- (instancetype)initWithDate:(NSDate *)date;

- (void)setTodoEvents:(NSArray *)todoEvents;

- (void)setScrollEnable:(BOOL)enabled;

@end
