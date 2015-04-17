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

@end

@implementation EditableTextViewController


#pragma mark - Life cycle

- (instancetype)initWithTitle:(NSString *)title text:(NSString *)text
{
    self = [super init];
    if (self) {
        self.originalText = text;
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureNavigationItem];
    [self setupViews];
    [self configureViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
}

- (void)viewDidLayoutSubviews
{
    self.textView.frame = self.view.bounds;
}


#pragma mark - Configuration

- (void)configureNavigationItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
}


- (void)setupViews
{
    self.textView = [[UITextView alloc] init];
    [self.view addSubview:self.textView];
}

- (void)configureViews
{
    self.textView.editable = YES;
    self.textView.font = [UIFont systemFontOfSize:18];
    self.textView.textContainerInset = UIEdgeInsetsMake(20, 10, 20, 10);
    self.textView.text = self.originalText;
}

- (NSString *)text
{
    return self.textView.text;
}


#pragma mark - Actions

- (void)cancelButtonPressed:(id)sender
{
    if (![self.originalText isEqual:self.textView.text]) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [ac addAction:[UIAlertAction actionWithTitle:@"Discard Changes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self.delegate editableTextViewController:self didCompleteWithAction:EditableTextViewActionCanceled];
        }]];
        [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:ac animated:YES completion:nil];
    } else {
        [self.delegate editableTextViewController:self didCompleteWithAction:EditableTextViewActionCanceled];
    }
}

- (void)doneButtonPressed:(id)sender
{
    [self.delegate editableTextViewController:self didCompleteWithAction:EditableTextViewActionSaved];
}

@end
