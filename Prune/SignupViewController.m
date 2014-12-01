//
//  SignupViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 12/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "SignupViewController.h"
#import "DAYAnalytics.h"
#import "SAMTextField.h"

@interface SignupViewController () <UITextFieldDelegate>

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.emailField.layer.cornerRadius = 5;
    self.emailField.textEdgeInsets = UIEdgeInsetsMake(11, 10, 9, 10);
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.emailField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *email = self.emailField.text;
    
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"userEmail"];
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"userHasOnboarded"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"userOnboardedAt"];
    [[DAYAnalytics sharedAnalytics] identify:email traits:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    [self presentViewController:[storyboard instantiateInitialViewController] animated:YES completion:nil];
    
    return YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
