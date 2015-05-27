//
//  Event.h
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface Event : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *eventDescription;
@property (nonatomic, strong) Location *location;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, assign) NSUInteger minParticipants;
@property (nonatomic, assign) NSUInteger maxParticipants;
@property (nonatomic, copy) NSDate *startTime;
@property (nonatomic, copy) NSDate *cutoffTime;

-(id)init:(NSDictionary *)event;

@end
