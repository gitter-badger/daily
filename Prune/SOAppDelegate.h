//
//  SOAppDelegate.h
//  ServiceOrientedAppDelegate
//
//  Created by Nico Hämäläinen on 09/02/14.
//  Copyright (c) 2014 Nico Hämäläinen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

- (NSArray *)services;

@end
