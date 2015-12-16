//
//  School.m
//  Pow Wow
//
//  Created by Will Parks on 12/15/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import "School.h"

@implementation School

@synthesize schoolId = _schoolId;
@synthesize name = _name;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

- (id)init {
    self = [super init];
    if (self) {
        self.schoolId = @"";
        self.name = @"";
        self.latitude = 0;
        self.longitude = 0;
    }
    return self;
}

- (id)init:(NSDictionary *)school {
    self = [super init];
    if (self) {
        self.schoolId = [school objectForKey:@"id"];
        self.name = [school objectForKey:@"name"];
        self.latitude = [[school objectForKey:@"latitude"] isMemberOfClass:[NSNull class]] ? 0 : [[school objectForKey:@"latitude"] doubleValue];
        self.longitude = [[school objectForKey:@"longitude"] isMemberOfClass:[NSNull class]] ? 0 : [[school objectForKey:@"longitude"] doubleValue];
    }
    return self;
}

+(void)get:(double)latitude longitdue:(double)longitude completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"School"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%f", latitude] forKey:@"latitude"];
    [params setValue:[NSString stringWithFormat:@"%f", longitude] forKey:@"longitude"];
    
    [service getByProc:@"getcloseschools" params:params completion:^(NSArray *results) {
        for(id item in results) {
            School *school = [[School alloc] init:item];
            completion(school);
        }
        completion(NULL);
    }];
}

@end
