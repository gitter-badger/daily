//
//  Todo.h
//  Daily
//
//  Created by Viktor Fröberg on 03/11/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Todo : NSManagedObject

@property (nonatomic, retain) NSString * todoIdentifier;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSDate   * date;
@property (nonatomic, retain) NSString * eventIdentifier;

@end
