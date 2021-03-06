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
#import "GroupUsers.h"
#import "User.h"
#import "PushMessage.h"

@interface Group : NSObject

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *pictureUrl;
@property (nonatomic, copy) NSString *schoolId;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *locations;
@property (nonatomic, assign) int orderBy;
@property (nonatomic, assign) BOOL isInvitedtoEvent;
@property (nonatomic, assign) int tagId;
@property (nonatomic, assign) BOOL hasImage;

@property (nonatomic, copy) NSArray *members;

-(id)init:(NSDictionary *)group;
+(void)get:(NSString *)groupId completion:(QSCompletionBlock)completion;
+(void)getBySchool:(QSCompletionBlock)completion;
+(void)getByUser:(NSString *)userId completion:(QSCompletionBlock)completion;
-(void)addMember:(NSString *)userId isAdmin:(BOOL)isAdmin;
-(void)removeMember:(NSString *)userId;
-(void)isAdmin:(QSCompletionBlock)completion;
+(void)clearIsInvitedToEvent;
-(void)save:(QSCompletionBlock)completion;
+(void)inviteGroups:(NSArray *)groups event:(Event *)event completion:(QSCompletionBlock)completion;
-(void)addImage:(UIImage *)image completion:(QSCompletionBlock)completion;

-(BOOL)isMember;

@end
