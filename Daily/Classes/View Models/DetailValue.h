//
//  DetailValue.h
//  Daily
//
//  Created by Viktor Fröberg on 17/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailValue : NSObject

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *value;

- (instancetype)initWithKey:(NSString *)key value:(NSString *)value placeholder:(NSString *)placeholder icon:(UIImage *)icon;

@end
