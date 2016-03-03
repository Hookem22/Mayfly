//
//  Message.h
//  Pow Wow
//
//  Created by Will Parks on 6/23/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSAzureService.h"
#import "QSAzureImageService.h"
#import "School.h"
#import "User.h"
#import "Session.h"
#import "Comment.h"

@interface Post : NSObject

@property (nonatomic, copy) NSString *postId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, assign) BOOL groupIsPublic;
@property (nonatomic, assign) NSInteger secondsSince;
@property (nonatomic, copy) NSDate *sentDate;
@property (nonatomic, copy) NSString *schoolId;
@property (nonatomic, assign) BOOL hasImage;
@property (nonatomic, retain) NSMutableArray *upVotes;
@property (nonatomic, retain) NSMutableArray *downVotes;
@property (nonatomic, retain) NSMutableArray *comments;

@property (nonatomic, assign) int votes;

-(id)init:(NSDictionary *)message;
+(void)get:(QSCompletionBlock)completion;
+(void)get:(NSString *)postId completion:(QSCompletionBlock)completion;
-(void)save:(QSCompletionBlock)completion;
-(void)addImage:(UIImage *)image completion:(QSCompletionBlock)completion;
-(BOOL)isPrivate;
-(void)deletePost:(QSCompletionBlock)completion;

@end
