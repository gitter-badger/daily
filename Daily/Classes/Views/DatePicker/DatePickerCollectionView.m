//
//  DatePickerCollectionView.m
//  Daily
//
//  Created by Viktor Fröberg on 19/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "DatePickerCollectionView.h"

@interface DatePickerCollectionView () <UIGestureRecognizerDelegate>

@end

@implementation DatePickerCollectionView

- (BOOL)isDatePickerView
{
    return YES;
}

- (UIColor *)selfBackgroundColor
{
    return [UIColor clearColor];
}

@end
