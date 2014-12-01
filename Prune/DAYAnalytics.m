//
//  DAYAnalytics.m
//  Daily
//
//  Created by Viktor Fröberg on 19/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Analytics.h>

#import "DAYAnalytics.h"

@interface DAYAnalytics ()

@property (nonatomic, strong) SEGAnalytics *segmentAnalytics;

@end

@implementation DAYAnalytics

+ (instancetype)sharedAnalytics
{
    static DAYAnalytics *sharedAnalytics;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAnalytics = [[DAYAnalytics alloc] init];
        sharedAnalytics.segmentAnalytics = [[SEGAnalytics alloc] initWithConfiguration:[SEGAnalyticsConfiguration configurationWithWriteKey:@"NAMIQqW2iS"]];
    });
    return sharedAnalytics;
}

- (void)identify:(NSString *)email
{
    [self.segmentAnalytics identify:email];
}

- (void)identify:(NSString *)email traits:(NSDictionary *)traits
{
    [self.segmentAnalytics identify:email traits:traits];
}

- (void)track:(NSString *)event
{
    [self.segmentAnalytics track:event];
}

- (void)track:(NSString *)event properties:(NSDictionary *)properties
{
    [self.segmentAnalytics track:event properties:properties];
}

- (void)screen:(NSString *)screen
{
    [self.segmentAnalytics screen:screen];
}

@end
