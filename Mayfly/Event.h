//
//  Event.h
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSAzureService.h"
#import "Location.h"
#import "Session.h"
#import "School.h"
#import "EventGoing.h"
#import "Message.h"

@interface Event : NSObject

@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *groupPictureUrl;
@property (nonatomic, assign) BOOL groupIsPublic;
@property (nonatomic, strong) Location *location;
@property (nonatomic, assign) NSUInteger minParticipants;
@property (nonatomic, assign) NSUInteger maxParticipants;
@property (nonatomic, copy) NSDate *startTime;
@property (nonatomic, assign) NSUInteger referenceId;
@property (nonatomic, assign) NSUInteger dayOfWeek;
@property (nonatomic, copy) NSString *localTime;
@property (nonatomic, copy) NSString *schoolId;
@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic, assign) int tagId;

@property (nonatomic, copy) NSArray *going;
@property (nonatomic, copy) NSArray *invited;
@property (nonatomic, copy) NSArray *messages;

-(id)init:(NSDictionary *)event;
-(id)initFromUrl:(NSString *)url;
+(void)get:(QSCompletionBlock)completion;
+(void)get:(NSString *)eventId completion:(QSCompletionBlock)completion;
+(void)getByReferenceId:(NSString *)referenceId completion:(QSCompletionBlock)completion;
+(void)getBySchool:(QSCompletionBlock)completion;
-(void)save:(QSCompletionBlock)completion;

+(void)getGoingByUserId:(NSString *)userId completion:(QSCompletionBlock)completion;
-(void)addGoing:(NSString *)userId isAdmin:(BOOL)isAdmin;
-(void)removeGoing:(NSString *)userId;
+(void)getInvitedByUserId:(NSString *)userId completion:(QSCompletionBlock)completion;
-(void)addInvite:(NSString *)facebookId name:(NSString *)name completion:(QSCompletionBlock)completion;
-(BOOL)isGoing;
-(BOOL)isInvited;
-(BOOL)isPrivate;
-(void)sendMessageToEvent:(NSString *)message info:(NSString *)info;
-(void)deleteEvent:(QSCompletionBlock)completion;

@end
