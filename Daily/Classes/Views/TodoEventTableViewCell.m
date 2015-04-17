//
//  TodoEventTableViewCell.m
//  Daily
//
//  Created by Viktor Fröberg on 09/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "TodoEventTableViewCell.h"

@interface TodoEventTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *checkboxButton;

@end

@implementation TodoEventTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.checkboxButton = [[UIButton alloc] init];
    [self.checkboxButton addTarget:self action:@selector(checkboxDidReceiveTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.checkboxButton];
    
    self.titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.titleLabel];
    
    self.detailLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.detailLabel];
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
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    self.detailLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.detailLabel.frame);
}

- (void)checkboxDidReceiveTap:(id)sender
{
    [self.delegate todoEventTableViewCellDidToggleCheckbox:self];
}

- (void)configureWithTitle:(NSString *)title time:(NSString *)time completed:(BOOL)completed
{
    NSDictionary *styles = [self styles];
    
    NSDictionary *titleStyles = completed ? styles[@"titleCompleted"] : styles[@"title"];
    NSDictionary *detailStyles = completed ? styles[@"detailCompleted"] : styles[@"detail"];
    NSDictionary *checkboxStyles = completed ? styles[@"checkboxCompleted"] : styles[@"checkbox"];
    
    self.checkboxButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = @{@"titleLabel": self.titleLabel, @"detailLabel": self.detailLabel, @"checkboxButton": self.checkboxButton};
    
    NSNumber *titleDetailSpacing = time.length ? @5 : @0;
    
    // Remove contraints
    [self.contentView removeConstraints:self.contentView.constraints];
    
    // Setup contraints
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[titleLabel]-spacing-[detailLabel]-20-|" options:0 metrics:@{@"spacing": titleDetailSpacing} views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[checkboxButton]-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[checkboxButton(==46)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-61-[titleLabel]-20-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-61-[detailLabel]-20-|" options:0 metrics:nil views:views]];
    
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = titleStyles[@"font"];
    self.titleLabel.textColor = titleStyles[@"textColor"];
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:@{NSStrikethroughStyleAttributeName: titleStyles[@"strikethroughStyle"]}];
    
    self.detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.font = detailStyles[@"font"];
    self.detailLabel.textColor = detailStyles[@"textColor"];
    self.detailLabel.attributedText = [[NSAttributedString alloc] initWithString:time attributes:@{NSStrikethroughStyleAttributeName: detailStyles[@"strikethroughStyle"]}];
    
    [self.checkboxButton setImage:checkboxStyles[@"image"] forState:UIControlStateNormal];
}

- (NSDictionary *)styles
{
    NSMutableDictionary *styles = [NSMutableDictionary dictionary];
    
    styles[@"title"] = @{@"font": [UIFont fontWithName:@"Palatino-Roman" size:19],
                         @"textColor": [UIColor colorWithRed:0 green:0 blue:0 alpha:1],
                         @"strikethroughStyle": [NSNumber numberWithInt:NSUnderlineStyleNone]};
    
    styles[@"titleCompleted"] = @{@"font": styles[@"title"][@"font"],
                                  @"textColor": [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1],
                                  @"strikethroughStyle": [NSNumber numberWithInt:NSUnderlineStyleSingle]};
    
    styles[@"detail"] = @{@"font": [UIFont fontWithName:@"Palatino-Roman" size:16],
                          @"textColor": [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1],
                          @"strikethroughStyle": [NSNumber numberWithInt:NSUnderlineStyleNone]};
    
    styles[@"detailCompleted"] = @{@"font": styles[@"detail"][@"font"],
                                   @"textColor": [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1],
                                   @"strikethroughStyle": [NSNumber numberWithInt:NSUnderlineStyleSingle]};
    
    styles[@"checkbox"] = @{@"image": [UIImage imageNamed:@"checkbox-off"]};
    
    styles[@"checkboxCompleted"] = @{@"image": [UIImage imageNamed:@"checkbox-on"]};
    
    return styles;
}

@end
