//
//  Location.m
//  Mayfly
//
//  Created by Will Parks on 5/27/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "Location.h"

@implementation Location

@synthesize name;
@synthesize address;
@synthesize latitude;
@synthesize longitude;

- (id)init:(NSDictionary *)location {
    self = [super init];
    if (self) {
        self.name = [location valueForKey:@"name"];
        self.address = [location valueForKey:@"address"];
        self.latitude = [[location valueForKey:@"latitude"] isMemberOfClass:[NSNull class]] ? 0 : [[location valueForKey:@"latitude"] doubleValue];
        self.longitude = [[location valueForKey:@"longitude"] isMemberOfClass:[NSNull class]] ? 0 : [[location valueForKey:@"longitude"] doubleValue];
    }
    return self;
}


@end
