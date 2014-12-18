//
//  DAYAnalytics.m
//  Daily
//
//  Created by Viktor Fröberg on 19/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Intercom/Intercom.h>

#import "Analytics.h"

@interface Analytics ()

@property (nonatomic, strong) Intercom *intercom;

@end

@implementation Analytics

+ (instancetype)sharedAnalytics
{
    static Analytics *sharedAnalytics;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAnalytics = [[Analytics alloc] init];
        [Intercom setApiKey:@"ios_sdk-d68ee30c837ece89ec811d139e24926c3706e4c5" forAppId:@"g48d527q"];
        [Intercom setPresentationMode:ICMPresentationModeBottomRight];
        [Intercom setPresentationInsetOverScreen:UIEdgeInsetsMake(20, 16, 80, 8)];
    });
    return sharedAnalytics;
}

- (void)identify:(NSString *)email
{
    [Intercom beginSessionForUserWithEmail:email completion:nil];
}

- (void)track:(NSString *)event
{
    [self track:event properties:nil];
}

- (void)track:(NSString *)event properties:(NSDictionary *)properties
{
    [Intercom logEventWithName:event optionalMetaData:properties completion:nil];
    if ([event isEqualToString:@"Completed Event"]) {
        NSNumber *lastCompleted = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
        [Intercom updateUserWithAttributes:@{ @"custom_attributes": @{ @"Last Completed": lastCompleted } } completion:nil];
    }
}

- (void)presentMessageView
{
    [Intercom presentMessageViewAsConversationList:YES];
}

@end
