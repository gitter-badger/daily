//
//  DateHeaderView.h
//  Daily
//
//  Created by Viktor Fröberg on 20/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateHeaderView : UIView

@property (nonatomic, strong, readonly) NSDate *date;

- (instancetype)initWithDate:(NSDate *)date;

@end
