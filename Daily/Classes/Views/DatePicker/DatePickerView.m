//
//  MonthDatePickerView.m
//  
//
//  Created by Viktor Fröberg on 19/01/15.
//
//

#import "DatePickerView.h"

#import "DatePickerCollectionView.h"
#import "DatePickerDaysOfWeekView.h"
#import "DatePickerDayCell.h"
#import "DatePickerMonthHeader.h"

@implementation DatePickerView

- (Class)daysOfWeekViewClass
{
    return [DatePickerDaysOfWeekView class];
}

- (Class)collectionViewClass
{
    return [DatePickerCollectionView class];
}

//- (Class)collectionViewLayoutClass
//{
//    return [RSDFCustomDatePickerCollectionViewLayout class];
//}

- (Class)monthHeaderClass
{
    return [DatePickerMonthHeader class];
}

- (Class)dayCellClass
{
    return [DatePickerDayCell class];
}

@end
