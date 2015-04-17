//
//  DetailTableViewCell.h
//  Daily
//
//  Created by Viktor Fröberg on 18/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailValue.h"

@interface DetailTableViewCell : UITableViewCell

- (void)configureWithDetailValue:(DetailValue *)detailValue;
- (void)configureWithTitle:(NSString *)title placeholder:(NSString *)placeholder icon:(UIImage *)icon;

@end
