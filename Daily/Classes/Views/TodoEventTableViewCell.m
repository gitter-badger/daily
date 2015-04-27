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

#pragma mark - Properties

- (CGFloat)estimatedHeight
{
    CGFloat padding = 20.0;
    return CGRectGetMaxY(self.detailLabel.frame) + padding;
}

#pragma mark - Life cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.checkboxButton = [[UIButton alloc] init];
        [self.checkboxButton addTarget:self action:@selector(checkboxDidReceiveTap:) forControlEvents:UIControlEventTouchUpInside];
        self.titleLabel = [[UILabel alloc] init];
        self.detailLabel = [[UILabel alloc] init];
        
        [self.contentView setSubviews:@[self.checkboxButton, self.titleLabel, self.detailLabel]];
    }
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect titleFrame = CGRectMake(60.0, 20.0, CGRectGetWidth(self.bounds) - 70.0, CGFLOAT_MAX);
    CGRect titleFrameCalculated = [self.titleLabel.attributedText boundingRectWithSize:titleFrame.size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
    titleFrame.size = titleFrameCalculated.size;
    self.titleLabel.frame = titleFrame;

    CGRect detailFrame = CGRectMake(60.0, CGRectGetMaxY(titleFrame), CGRectGetWidth(self.bounds) - 70.0, CGFLOAT_MAX);
    if (self.detailLabel.attributedText.string.length) {
        detailFrame.origin.y += 5.0;
        CGRect detailFrameCalculated = [self.detailLabel.attributedText boundingRectWithSize:detailFrame.size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
        detailFrame.size = detailFrameCalculated.size;
    } else {
        detailFrame.size = CGSizeMake(0, 0);
    }
    self.detailLabel.frame = detailFrame;
    
    self.checkboxButton.frame = CGRectMake(0, CGRectGetMidY(self.bounds) - 23.0, 46.0, 46.0);
}

#pragma mark - Configure

- (void)configureWithViewModel:(TodoEventViewModel *)viewModel delegate:(id<TodoEventTableViewCellDelegate>)delegate
{
    [self configureWithTitle:viewModel.titleText time:viewModel.timeText completed:viewModel.completed delegate:delegate];
}

- (void)configureWithTitle:(NSString *)title time:(NSString *)time completed:(BOOL)completed delegate:(id<TodoEventTableViewCellDelegate>)delegate
{
    self.delegate = delegate;
    
    NSDictionary *styles = [self styles];
    
    NSDictionary *titleStyles = completed ? styles[@"titleCompleted"] : styles[@"title"];
    NSDictionary *detailStyles = completed ? styles[@"detailCompleted"] : styles[@"detail"];
    NSDictionary *checkboxStyles = completed ? styles[@"checkboxCompleted"] : styles[@"checkbox"];
    
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textColor = titleStyles[@"textColor"];
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:
                                      @{NSStrikethroughStyleAttributeName: titleStyles[@"strikethroughStyle"],
                                        NSFontAttributeName: titleStyles[@"font"]}];
    
    self.detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.textColor = detailStyles[@"textColor"];
    self.detailLabel.attributedText = [[NSAttributedString alloc] initWithString:time attributes:
                                       @{NSStrikethroughStyleAttributeName: detailStyles[@"strikethroughStyle"],
                                         NSFontAttributeName: titleStyles[@"font"]}];
    
    [self.checkboxButton setImage:checkboxStyles[@"image"] forState:UIControlStateNormal];
}

#pragma mark - Actions

- (void)checkboxDidReceiveTap:(id)sender
{
    [self.delegate todoEventTableViewCellDidToggleCheckbox:self];
}

#pragma mark - Styles

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
    
    styles[@"checkbox"] = @{@"image": [TodoEventTableViewCell checkboxOffImage]};
    
    styles[@"checkboxCompleted"] = @{@"image": [TodoEventTableViewCell checkboxOnImage]};
    
    return styles;
}

+ (UIImage *)checkboxOffImage
{
    static UIImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"checkbox-off"];
    });
    return image;
}

+ (UIImage *)checkboxOnImage
{
    static UIImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"checkbox-on"];
    });
    return image;
}

@end
