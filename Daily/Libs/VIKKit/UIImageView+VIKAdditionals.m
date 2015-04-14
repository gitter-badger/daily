
//
//  UIImageView+VIKAdditionals.m
//  Daily
//
//  Created by Viktor Fröberg on 12/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "UIImageView+VIKAdditionals.h"

@implementation UIImageView (VIKAdditionals)

+ (UIImageView *)imageViewWithImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

@end
