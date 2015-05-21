//
//  Event.m
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "Event.h"

@implementation Event

@synthesize name;
@synthesize eventDesciption;
@synthesize location;
@synthesize isPrivate;
@synthesize minParticipants;
@synthesize maxParticipants;
@synthesize startTime;
@synthesize cutoffTime;

- (id)init:(NSDictionary *)event {
    self = [super init];
    if (self) {
        self.name = [event valueForKey:@"name"];
        self.eventDesciption = [event valueForKey:@"eventDesciption"];
        self.location = [event valueForKey:@"location"];
        self.isPrivate = [event valueForKey:@"isPrivate"];
        self.minParticipants = [[event valueForKey:@"minParticipants"] isMemberOfClass:[NSNull class]] ? 0 : [[event valueForKey:@"minParticipants"] longLongValue];
        self.maxParticipants = [[event valueForKey:@"maxParticipants"] isMemberOfClass:[NSNull class]] ? 0 : [[event valueForKey:@"maxParticipants"] longLongValue];
        self.startTime = [event valueForKey:@"startTime"];
        self.cutoffTime = [event valueForKey:@"cutoffTime"];
    }
    return self;
}

@end
