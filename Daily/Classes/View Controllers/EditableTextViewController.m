//
//  EditableTextViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 14/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "EditableTextViewController.h"

#import "TodoEvent.h"

@interface EditableTextViewController ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSString *originalText;
@property (nonatomic, copy) EditableTextViewControllerBlock completion;

@end

@implementation EditableTextViewController

- (instancetype)initWithTitle:(NSString *)title text:(NSString *)text completion:(EditableTextViewControllerBlock)completion
{
    self = [super init];
    if (self) {
        self.completion = completion;
        self.originalText = text;
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    
    self.textView = [[UITextView alloc] init];
    self.textView.editable = YES;
    self.textView.font = [UIFont systemFontOfSize:18];
    self.textView.textContainerInset = UIEdgeInsetsMake(20, 10, 20, 10);
    self.textView.text = self.originalText;
    
    [self.view addSubview:self.textView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void)cancelButtonPressed:(id)sender
{
    if (![self.originalText isEqual:self.textView.text]) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [ac addAction:[UIAlertAction actionWithTitle:@"Discard Changes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            self.completion(NO, self.originalText);
        }]];
        [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:ac animated:YES completion:nil];
    } else {
        self.completion(NO, self.originalText);
    }
}

- (void)doneButtonPressed:(id)sender
{
    self.completion(YES, self.textView.text);
}

- (void)viewDidLayoutSubviews
{
    self.textView.frame = self.view.bounds;
}

@end
