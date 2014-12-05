//
//  UserDefaultsService.h
//  Daily
//
//  Created by Viktor Fröberg on 04/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsService : NSObject <UIApplicationDelegate>

+ (instancetype)sharedInstance;

@end
