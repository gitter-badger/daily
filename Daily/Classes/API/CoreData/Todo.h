//
//  Todo.h
//  Daily
//
//  Created by Viktor Fröberg on 27/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Todo : NSManagedObject

@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSString * todoIdentifier;

@end
