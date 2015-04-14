//
//  DatePickerDaysOfWeekView.m
//  Daily
//
//  Created by Viktor Fröberg on 19/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "DatePickerDaysOfWeekView.h"

@implementation DatePickerDaysOfWeekView

- (UIColor *)selfBackgroundColor
{
    return [UIColor clearColor];
}

//- (CGSize)selfItemSize;
//
//- (CGFloat)selfInteritemSpacing;
//
- (UIFont *)dayOfWeekLabelFont
{
    return [UIFont boldSystemFontOfSize:12];
}

- (UIColor *)dayOfWeekLabelTextColor {
    return [UIColor darkGrayColor];
}

- (UIColor *)dayOffOfWeekLabelTextColor
{
    return [UIColor darkGrayColor];
}

@end
