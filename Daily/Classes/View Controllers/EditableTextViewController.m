//
//  EditableTextViewController.m
//  Daily
//
//  Created by Viktor Fröberg on 14/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "EditableTextViewController.h"
#import "TodoEvent.h"

#define DCLOnce(ref, val) ref = ref ? ref : val
#define DCLSet(ref, val) if (ref != val) ref = val

@interface NSObject (Declarative)

- (void)setValueIfNeeded:(id)value forKey:(NSString *)key;

@end

@implementation NSObject (Declarative)

- (void)setValueIfNeeded:(id)value forKey:(NSString *)key
{
    id oldValue = [self valueForKey:key];
    if (![oldValue isEqual:value]) {
        [self setValue:value forKey:key];
    }
}

@end

@interface EditableTextViewController () <UITextViewDelegate>

// Properties
@property (nonatomic, strong) NSString *originalText;

// State
@property (nonatomic, strong) NSString *textViewText;

// Views
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

@end

@implementation EditableTextViewController


#pragma mark - Life cycle

- (instancetype)initWithTitle:(NSString *)title text:(NSString *)text
{
    self = [super init];
    if (self) {
        self.originalText = text;
        self.title = title;
        self.textViewText = self.originalText;
    }
    return self;
}

- (NSString *)text
{
    return self.textView.text;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self render];
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
    [self render];
}

- (void)render
{
    DCLOnce(self.textView, [[UITextView alloc] init]);
    
    self.textView.frame = self.view.bounds;
    self.textView.delegate = self;
    self.textView.editable = YES;
    self.textView.font = [UIFont systemFontOfSize:18];
    self.textView.textContainerInset = UIEdgeInsetsMake(20, 10, 20, 10);
    
    [self.textView setValueIfNeeded:self.textViewText forKey:@"text"];
    
    [self.view setSubviews:@[self.textView]];
    
    DCLOnce(self.cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)]);
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    
    DCLOnce(self.doneButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)]);
    self.navigationItem.rightBarButtonItem = self.doneButton;
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.textViewText = textView.text;
    [self render];
}


#pragma mark - Actions

- (void)cancelButtonPressed:(id)sender
{
    if ([self.originalText isEqual:self.textView.text]) {
        [self.delegate editableTextViewController:self didCompleteWithAction:EditableTextViewActionCanceled];
    } else {
        [self presentDiscardChangesActionSheet];
    }
}

- (void)discardChangesButtonPressed:(id)sender
{
    [self.delegate editableTextViewController:self didCompleteWithAction:EditableTextViewActionCanceled];
}

- (void)doneButtonPressed:(id)sender
{
    [self.delegate editableTextViewController:self didCompleteWithAction:EditableTextViewActionSaved];
}


#pragma mark - Factories

- (void)presentDiscardChangesActionSheet
{
    UIAlertController *alertController = [self discardChangesAlertController];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (UIAlertController *)discardChangesAlertController
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Discard Changes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self discardChangesButtonPressed:action];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    return alertController;
}

@end
