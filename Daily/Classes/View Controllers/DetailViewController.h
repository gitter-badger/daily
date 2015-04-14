//
//  DetailViewController.h
//  Daily
//
//  Created by Viktor Fröberg on 15/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MutableTodoEvent;

@interface DetailViewController : UITableViewController

- (instancetype)initWithTodoEvent:(MutableTodoEvent *)todoEvent;

@end
