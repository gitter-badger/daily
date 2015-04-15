//
//  EditableTextViewController.h
//  Daily
//
//  Created by Viktor Fröberg on 14/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^EditableTextViewControllerBlock)(BOOL success, NSString *text);

@interface EditableTextViewController : UIViewController

- (instancetype)initWithTitle:(NSString *)title text:(NSString *)text completion:(EditableTextViewControllerBlock)completion;

@end