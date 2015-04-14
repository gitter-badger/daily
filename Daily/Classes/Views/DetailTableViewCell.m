//
//  DetailTableViewCell.m
//  Daily
//
//  Created by Viktor Fröberg on 18/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "DetailTableViewCell.h"
#import "UIImage+Tint.h"

@interface DetailTableViewCell ()

@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation DetailTableViewCell

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconView];
    }
    return _iconView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.detailTextLabel.textColor = [UIColor grayColor];
        
        NSDictionary *views = @{@"textLabel": self.textLabel, @"detailTextLabel": self.detailTextLabel, @"iconView": self.iconView};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[textLabel]-5-[detailTextLabel]-10-|" options:0 metrics:nil views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[iconView(==16)]" options:0 metrics:nil views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[iconView(==16)]" options:0 metrics:nil views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-36-[textLabel]-10-|" options:0 metrics:nil views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-36-[detailTextLabel]-10-|" options:0 metrics:nil views:views]];
    }
    return self;
}

- (void)setTitleText:(NSString *)titleText placeholderText:(NSString *)placeholderText detailText:(NSString *)detailText iconImage:(UIImage *)image
{
    if (titleText.length) {
        self.textLabel.text = titleText;
        self.textLabel.textColor = [UIColor blackColor];
    } else {
        self.textLabel.text = placeholderText;
        self.textLabel.textColor = [UIColor lightGrayColor];
    }
    self.detailTextLabel.text = detailText;
    [self.iconView setImage:[image imageTintedWithColor:[UIColor grayColor]]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.textLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.textLabel.frame);
    self.detailTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.detailTextLabel.frame);
}

@end
