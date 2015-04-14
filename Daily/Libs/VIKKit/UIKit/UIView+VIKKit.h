//
//  UIView+Frame.h
//  BotKit
//
//  Created by theo on 4/16/13.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

CGPoint VIKRectCenter(CGRect rect);
CGRect VIKCenterRect(CGRect rect, CGPoint center);
CGRect VIKScaleRect(CGRect rect, CGPoint scale);
CGRect VIKScaleRect1D(CGRect rect, float scale);

CGPoint VIKAddPoints(CGPoint p1, CGPoint p2);
CGPoint VIKSubtractPoints(CGPoint p1, CGPoint p2);
CGPoint VIKScalePoint(CGPoint p1, CGPoint scale);
CGPoint VIKScalePoint1D(CGPoint p1, float scale);

CGRect VIKAddPointToRect(CGRect rect, CGPoint point);
CGRect VIKAddSizeToRect(CGRect rect, CGSize size);

CGRect VIKRectFromPoints(CGPoint top, CGPoint bottom);

CGPoint VIKTopLeftCorner(CGRect rect);
CGPoint VIKBottomLeftCorner(CGRect rect);
CGPoint VIKTopRightCorner(CGRect rect);
CGPoint VIKBottomRightCorner(CGRect rect);

@interface UIView (VIKKit)

- (void)setOrigin:(CGPoint)origin;
- (CGPoint)origin;

- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;
- (void)setX:(CGFloat)x Y:(CGFloat)y;
- (void)addToX:(CGFloat)amount;
- (void)addToY:(CGFloat)amount;
- (void)addToX:(CGFloat)xAmount Y:(CGFloat)yAmount;

- (void)setSize:(CGSize)size;
- (CGSize)size;

- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;
- (void)setWidth:(CGFloat)width height:(CGFloat)height;
- (void)addToWith:(CGFloat)amount;
- (void)addToHeight:(CGFloat)amount;
- (void)addToWidth:(CGFloat)widthAmount height:(CGFloat)heightAmount;

- (void)setTopLeftPoint:(CGPoint)topLeft bottomRightPoint:(CGPoint)bottomRight;

@end
