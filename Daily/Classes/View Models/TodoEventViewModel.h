//
//  TodoEventViewModel.h
//  Daily
//
//  Created by Viktor Fröberg on 16/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TodoEvent;

@interface TodoEventViewModel : NSObject

@property (nonatomic, copy, readonly) NSString *titleText;
@property (nonatomic, copy, readonly) NSString *locationText;
@property (nonatomic, copy, readonly) NSString *timeText;
@property (nonatomic, copy, readonly) NSString *notesText;
@property (nonatomic, copy, readonly) NSString *urlText;
@property (nonatomic, copy ,readonly) NSString *dateTextFull;
@property (nonatomic, copy ,readonly) NSString *dateText;
@property (nonatomic, readonly) BOOL completed;

- (instancetype)initWithTodoEvent:(TodoEvent *)todoEvent;

@end
