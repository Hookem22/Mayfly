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

- (id)init {
    self = [super init];
    if (self) {
        self.name = @"";
        self.address = @"";
        self.latitude = 0;
        self.longitude = 0;
    }
    return self;
}

- (id)init:(NSDictionary *)location {
    self = [super init];
    if (self) {
        self.name = [location objectForKey:@"name"];
        self.address = [location objectForKey:@"address"];
        self.latitude = [[location objectForKey:@"latitude"] isMemberOfClass:[NSNull class]] ? 0 : [[location objectForKey:@"latitude"] doubleValue];
        self.longitude = [[location objectForKey:@"longitude"] isMemberOfClass:[NSNull class]] ? 0 : [[location objectForKey:@"longitude"] doubleValue];
    }
    return self;
}


@end
