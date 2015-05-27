//
//  Location.h
//  Mayfly
//
//  Created by Will Parks on 5/27/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

-(id)init:(NSDictionary *)location;

@end
