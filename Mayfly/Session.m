//
//  Session.m
//  DishWish
//
//  Created by Will on 5/22/14.
//  Copyright (c) 2014 DishWish. All rights reserved.
//

#import "Session.h"

@implementation Session

static NSMutableDictionary *_sessionVariables;

// Get the shared instance and create it if necessary.
+ (NSMutableDictionary *)sessionVariables {
    if (_sessionVariables == nil) {
        _sessionVariables = [[NSMutableDictionary alloc] init];
    }
    
    return _sessionVariables;
}

@end