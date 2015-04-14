//
//  DAYAnalytics.h
//  Daily
//
//  Created by Viktor Fröberg on 19/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Analytics : NSObject

+ (instancetype)sharedAnalytics;

- (void)identify:(NSString *)email;

- (void)track:(NSString *)event;
- (void)track:(NSString *)event properties:(NSDictionary *)properties;

- (void)presentMessageView;

@end
