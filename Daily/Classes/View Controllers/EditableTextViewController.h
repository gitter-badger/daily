//
//  EditableTextViewController.h
//  Daily
//
//  Created by Viktor Fröberg on 14/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditableTextViewControllerDelegate;

@interface EditableTextViewController : UIViewController

@property (nonatomic, weak) id <EditableTextViewControllerDelegate> delegate;

- (NSString *)text;

- (instancetype)initWithTitle:(NSString *)title text:(NSString *)text;

@end

@protocol EditableTextViewControllerDelegate <NSObject>

typedef enum {
    EditableTextViewActionCanceled,
    EditableTextViewActionSaved,
} EditableTextViewAction;

- (void)editableTextViewController:(EditableTextViewController *)controller didCompleteWithAction:(EditableTextViewAction)action;

@end