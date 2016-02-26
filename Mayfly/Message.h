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
#import "Session.h"

@interface Message : NSObject

@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) NSInteger secondsSince;
@property (nonatomic, copy) NSString *viewedBy;
@property (nonatomic, copy) NSDate *sentDate;
@property (nonatomic, assign) BOOL hasImage;

-(id)init:(NSDictionary *)message;
+(void)get:(NSString *)eventId completion:(QSCompletionBlock)completion;
+(void)getImageByUser:(NSString *)userId completion:(QSCompletionBlock)completion;
-(void)save:(QSCompletionBlock)completion;
-(bool)isViewed;
-(void)markViewed;
-(void)addImage:(UIImage *)image completion:(QSCompletionBlock)completion;

@end
