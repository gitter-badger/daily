//
//  MTLModel+VIKKit.h
//  Daily
//
//  Created by Viktor Fröberg on 27/04/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "MTLModel.h"

@interface MTLModel (VIKKit)

- (instancetype)modelByAddingEntriesFromDictionary:(NSDictionary *)dictionary error:(NSError **)error;

@end
