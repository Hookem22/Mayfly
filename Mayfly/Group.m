//
//  Group.m
//  Pow Wow
//
//  Created by Will Parks on 12/29/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import "Group.h"

@implementation Group

@synthesize groupId = _groupId;
@synthesize name = _name;
@synthesize description = _description;
@synthesize pictureUrl = _pictureUrl;
@synthesize schoolId = _schoolId;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize city = _city;
@synthesize isPublic = _isPublic;
@synthesize password = _password;
@synthesize locations = _locations;
@synthesize orderBy = _orderBy;

-(id)init:(NSDictionary *)group {
    self = [super init];
    if (self) {
        self.groupId = [group valueForKey:@"groupid"];
        self.name = [group objectForKey:@"name"];
        self.description = [group objectForKey:@"description"];
        self.pictureUrl = [group objectForKey:@"pictureurl"];
        self.schoolId = [group objectForKey:@"schoolid"];
        self.latitude = [[group objectForKey:@"latitude"] isMemberOfClass:[NSNull class]] ? 0 : [[group objectForKey:@"latitude"] doubleValue];
        self.longitude = [[group objectForKey:@"longitude"] isMemberOfClass:[NSNull class]] ? 0 : [[group objectForKey:@"longitude"] doubleValue];
        self.city = [group objectForKey:@"city"];
        self.isPublic = [[group objectForKey:@"ispublic"] isMemberOfClass:[NSNull class]] ? TRUE : [[group objectForKey:@"schoolid"] boolValue];
        self.password = [group valueForKey:@"password"];
        self.locations = [group objectForKey:@"locations"];
        self.orderBy = [[group objectForKey:@"orderby"] isMemberOfClass:[NSNull class]] ? 0 : [[group objectForKey:@"orderby"] intValue];
    }
    return self;
}

+(void)getBySchool:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Group"];
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%@", school.schoolId] forKey:@"schoolid"];

    [service getByProc:@"getgroupsbyschool" params:params completion:^(NSArray *results) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for(id item in results) {
            Group *group = [[Group alloc] init:item];
            [list addObject:group];
        }
        completion(list);
    }];
}

-(void)save:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Group"];
    
    NSDictionary *group = @{@"name": self.name, @"description": self.description, @"pictureurl": self.pictureUrl, @"schoolid": self.schoolId, @"latitude": [NSNumber numberWithDouble:self.latitude], @"longitude": [NSNumber numberWithDouble:self.longitude], @"ispublic": [NSNumber numberWithBool:self.isPublic], @"password": self.password, @"orderBy": [NSNumber numberWithInt:self.orderBy] };
    
    if([self.groupId length] > 0) { //Update
        NSMutableDictionary *mutableEvent = [group mutableCopy];
        [mutableEvent setObject:self.groupId forKey:@"id"];
        [service updateItem:mutableEvent completion:^(NSDictionary *item)
         {
             completion(self);
         }];
    }
    else //Add
    {
        [service addItem:group completion:^(NSDictionary *item)
         {
             self.groupId = [item objectForKey:@"id"];
             completion(self);
         }];
    }
    
}

@end
