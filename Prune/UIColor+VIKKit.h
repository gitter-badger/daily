//
//  UIColor+AdjustColor.h
//  CountIt
//
//  Created by Mark Adams on 10/2/12.
//  Copyright (c) 2014 CountIt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (VIKKit)

- (UIColor *)adjustColorByAmount:(CGFloat)amount;
- (NSString *)stringValue;
- (NSString *)hexStringValue;

+ (UIColor *)colorFromString:(NSString *)colorString;
+ (UIColor *)colorFromHexString:(NSString *)hexString;

@end
