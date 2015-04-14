//
//  DatePickerDayCell.m
//  Daily
//
//  Created by Viktor Fröberg on 19/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "DatePickerDayCell.h"

@implementation DatePickerDayCell

- (UIColor *)dayLabelTextColor
{
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
}

- (UIColor *)dayOffLabelTextColor
{
    return self.dayLabelTextColor;
}

- (UIColor *)todayLabelTextColor
{
    return [UIColor redColor];
}

#pragma mark - Font

- (UIFont *)dayLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue" size:18];
}

- (UIFont *)todayLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue" size:18];
}
- (UIFont *)selectedTodayLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue" size:18];
}
- (UIFont *)selectedDayLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue" size:18];
}

- (UIColor *)selectedDayLabelTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)selectedDayImageColor
{
    return [UIColor whiteColor];
}

- (UIColor *)selectedTodayLabelTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)selectedTodayImageColor
{
    return [UIColor redColor];
}

- (UIColor *)dividerImageColor
{
    return [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
}

- (UIColor *)notThisMonthLabelTextColor
{
    return [UIColor clearColor];
}

//- (UIColor *)selfBackgroundColor;
//
//- (UIImage *)customSelectedTodayImage;
//
//- (UIImage *)customSelectedDayImage;
//
//- (UIColor *)overlayImageColor;
//
//- (UIImage *)customOverlayImage;
//
//- (UIColor *)incompleteMarkImageColor;
//
//- (UIImage *)customIncompleteMarkImage;
//
//- (UIColor *)completeMarkImageColor;
//
//- (UIImage *)customCompleteMarkImage;
//
//- (UIColor *)dividerImageColor;
//
//- (UIImage *)customDividerImage;

@end
