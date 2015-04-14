//
//  Dispatcher.h
//  Daily
//
//  Created by Viktor Fröberg on 27/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import "CLAFluxDispatcher.h"

@interface Dispatcher : CLAFluxDispatcher

+ (instancetype)sharedDispatcher;

@end
