//
//  TodoEventViewModel.h
//  Daily
//
//  Created by Viktor Fröberg on 16/03/15.
//  Copyright (c) 2015 Viktor Fröberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MutableTodoEvent;

@interface TodoEventViewModel : NSObject

@property (nonatomic, strong, readonly) NSString *titleText;
@property (nonatomic, strong, readonly) NSString *locationText;
@property (nonatomic, strong, readonly) NSString *timeText;
@property (nonatomic, strong, readonly) NSString *notesText;
@property (nonatomic, strong, readonly) NSString *urlText;
@property (nonatomic, strong ,readonly) NSString *dateTextFull;
@property (nonatomic, strong ,readonly) NSString *dateText;
@property (nonatomic, readonly) BOOL completed;

- (instancetype)initWithTodoEvent:(MutableTodoEvent *)todoEvent;

@end
