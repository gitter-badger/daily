//
//  ApplicationViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 19/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "ApplicationViewController.h"
#import "NSUserDefaults+DLY.h"

#import "MainViewController.h"
#import "DatePickerViewController.h"
#import "ListViewController.h"

@implementation ApplicationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    BOOL userHasOnboarded = [[NSUserDefaults standardUserDefaults] userHasOboarded];
    if (userHasOnboarded) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
        [self presentViewController:[storyboard instantiateInitialViewController] animated:NO completion:nil];
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboard_iPhone" bundle:[NSBundle mainBundle]];
        [self presentViewController:[storyboard instantiateInitialViewController] animated:NO completion:nil];
    }
}

@end
