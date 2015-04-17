//
//  FloatingButton.m
//  Daily
//
//  Created by Viktor Fröberg on 02/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "FloatingButton.h"

@implementation FloatingButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureViews];
    }
    return self;
}

- (void)configureViews
{
    self.backgroundColor = [UIColor redColor];
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.layer.cornerRadius = 25;
    
    self.titleLabel.font = [UIFont systemFontOfSize:24];
    self.titleLabel.textColor = [UIColor whiteColor];
}

@end
