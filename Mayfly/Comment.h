//
//  Comment.h
//  Pow Wow
//
//  Created by Will Parks on 3/2/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSAzureService.h"

@interface Comment : NSObject

@property (nonatomic, copy) NSString *commentId;
@property (nonatomic, copy) NSString *postId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) NSInteger secondsSince;
@property (nonatomic, copy) NSDate *sentDate;
@property (nonatomic, assign) BOOL hasImage;

+(void)get:(NSString *)postId completion:(QSCompletionBlock)completion;
-(void)save:(QSCompletionBlock)completion;
-(void)deleteComment:(QSCompletionBlock)completion;

@end
