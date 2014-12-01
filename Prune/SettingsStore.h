//
//  SettingsStore.h
//  Daily
//
//  Created by Viktor Fröberg on 21/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsStore : NSObject

+ (instancetype)sharedSettingsStore;

- (NSArray *)calendarIdentifiers;
- (void)setCalendarIdentifiers:(NSArray *)calendarIdentifiers;

- (NSArray *)calendars;
- (void)setCalendars:(NSArray *)selectedCalendars;

@end
