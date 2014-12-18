//
//  Calendar+VFDaily.m
//  Daily
//
//  Created by Viktor Fröberg on 05/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import "Calendar+VFDaily.h"

@implementation Calendar (VFDaily)

- (void)awakeFromInsert
{
    self.enabledDate = [NSDate date];
}

@end
