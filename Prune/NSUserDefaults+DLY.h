//
//  NSUserDefaults+DLY.h
//  Daily
//
//  Created by Viktor Fröberg on 01/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (DLY)

- (NSString *)email;
- (void)setEmail:(NSString *)email;

- (NSDate *)created;
- (void)setCreated:(NSDate *)date;

- (NSDate *)lastSeen;
- (void)setLastSeen:(NSDate *)date;

@end
