//
//  VIKTextFieldCell.m
//  Daily
//
//  Created by Viktor Fröberg on 13/01/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "VIKTextFieldCell.h"

@interface VIKTextFieldCell ()

@property (nonatomic, strong, readwrite) UITextField *textField;

@end

@implementation VIKTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textField = [[UITextField alloc] init];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textField.frame = CGRectInset(self.contentView.bounds, 15, 8);
}

@end
