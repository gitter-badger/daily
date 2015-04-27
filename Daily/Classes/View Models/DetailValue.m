//
//  DetailValue.m
//  Daily
//
//  Created by Viktor Fröberg on 17/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "DetailValue.h"

@interface DetailValue ()

@property (nonatomic, copy) UIImage *icon;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *value;

@end

@implementation DetailValue

- (instancetype)initWithKey:(NSString *)key value:(NSString *)value placeholder:(NSString *)placeholder icon:(UIImage *)icon
{
    self = [super init];
    if (self) {
        self.key = key;
        self.value = value;
        self.placeholder = placeholder;
        self.icon = icon;
    }
    return self;
}

@end
