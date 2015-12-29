//
//  Group.h
//  Pow Wow
//
//  Created by Will Parks on 12/29/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSAzureService.h"
#import "Session.h"
#import "School.h"

@interface Group : NSObject

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *pictureUrl;
@property (nonatomic, copy) NSString *schoolId;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, assign) bool isPublic;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *locations;
@property (nonatomic, assign) int orderBy;

-(id)init:(NSDictionary *)group;
+(void)getBySchool:(QSCompletionBlock)completion;
-(void)save:(QSCompletionBlock)completion;

@end
