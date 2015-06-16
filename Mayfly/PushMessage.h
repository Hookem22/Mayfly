//
//  PushMessage.h
//  Mayfly
//
//  Created by Will Parks on 6/8/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSAzureService.h"
#import "User.h"

@interface PushMessage : NSObject

@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSDate *sentDate;

-(id)init:(NSDictionary *)pushMessage;
+(void)get:(NSString *)eventId completion:(QSCompletionBlock)completion;
-(void)save:(QSCompletionBlock)completion;

+(void)push:(NSString *)deviceToken  header:(NSString *)header message:(NSString *)message;
+(void)pushByEvent:(Event *)event header:(NSString *)header message:(NSString *)message;
+(void)inviteFriends:(NSArray *)facebookIds from:(NSString *)from message:(NSString *)message;

@end
