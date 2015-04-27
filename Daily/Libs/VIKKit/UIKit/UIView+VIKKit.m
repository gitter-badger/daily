//
//  UIView+Frame.m
//  BotKit
//
//  Created by theo on 4/16/13.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "UIView+VIKKit.h"

@implementation UIView (VIKKit)

- (void)setSubviews:(NSArray *)subviews
{
    NSArray *removedSubviews = [self.subviews select:^BOOL(id object) {
        return ![subviews containsObject:object];
    }];

    NSArray *addedSubviews = [subviews select:^BOOL(id object) {
        return ![self.subviews containsObject:object];
    }];
    
    [removedSubviews each:^(UIView *view) {
        [view removeFromSuperview];
    }];

    [addedSubviews each:^(UIView *view) {
        [self addSubview:view];
    }];
}

@end
