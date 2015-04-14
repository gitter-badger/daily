//
//  SignupViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 12/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "SignupViewController.h"

#import "NSUserDefaults+DLY.h"

#import "SAMTextField.h"

#import "MainViewController.h"

@interface SignupViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet SAMTextField *emailField;

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
    [super viewDidAppear:animated];
    [self.emailField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *email = self.emailField.text;
    NSDate *now = [NSDate date];
    
    [[NSUserDefaults standardUserDefaults] setEmail:email];
    [[NSUserDefaults standardUserDefaults] setCreated:now];
    
    MainViewController *vc = [[MainViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
    
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
