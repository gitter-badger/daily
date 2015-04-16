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
    self.textLabel.hidden = YES;
    self.detailTextLabel.hidden = YES;
    
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
    self.checkboxButton.frame = CGRectMake(0, 0, 64, CGRectGetHeight(self.bounds));
    self.titleLabel.frame = CGRectMake(64, 22, CGRectGetWidth(self.bounds) - 64 - 20, 21);
    self.detailLabel.frame = CGRectMake(64, 48, CGRectGetWidth(self.bounds) - 64 - 20, 18);
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
    
    self.titleLabel.font = titleStyles[@"font"];
    self.titleLabel.textColor = titleStyles[@"textColor"];
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:@{NSStrikethroughStyleAttributeName: titleStyles[@"strikethroughStyle"]}];
    
    self.detailLabel.font = detailStyles[@"font"];
    self.detailLabel.textColor = detailStyles[@"textColor"];
    self.detailLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:@{NSStrikethroughStyleAttributeName: detailStyles[@"strikethroughStyle"]}];
    
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
