//
//  Calendar.h
//  Daily
//
//  Created by Viktor Fröberg on 04/12/14.
//  Copyright (c) 2014 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Calendar : NSManagedObject

@property (nonatomic, retain) NSDate * enabledDate;
@property (nonatomic, retain) NSString *calendarIdentifier;

@end
