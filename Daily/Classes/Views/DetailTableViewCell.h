//
//  DetailTableViewCell.h
//  Daily
//
//  Created by Viktor Fröberg on 18/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailTableViewCell : UITableViewCell

- (void)setTitleText:(NSString *)titleText placeholderText:(NSString *)placeholderText detailText:(NSString *)detailText iconImage:(UIImage *)image;

@end
