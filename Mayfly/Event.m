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
@synthesize eventDescription;
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
        self.eventDescription = [event valueForKey:@"eventDescription"];
        self.location = [[Location alloc] init:[event valueForKey:@"location"]];
        self.isPrivate = [[event valueForKey:@"isPrivate"] isMemberOfClass:[NSNull class]] ? YES : [[event valueForKey:@"isPrivate"] boolValue];
        self.minParticipants = [[event valueForKey:@"minParticipants"] isMemberOfClass:[NSNull class]] ? 0 : [[event valueForKey:@"minParticipants"] intValue];
        self.maxParticipants = [[event valueForKey:@"maxParticipants"] isMemberOfClass:[NSNull class]] ? 0 : [[event valueForKey:@"maxParticipants"] intValue];
        self.startTime = [event valueForKey:@"startTime"];
        self.cutoffTime = [event valueForKey:@"cutoffTime"];
    }
    return self;
}

@end
