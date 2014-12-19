//
//  CrashlyticsService.m
//  Daily
//
//  Created by Viktor Fröberg on 19/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "CrashlyticsService.h"

@implementation CrashlyticsService

- (void)startLogging
{
    [Crashlytics startWithAPIKey:@"fb76caedaff89b29a1a7205381ace5d25c832964"];
}

@end
