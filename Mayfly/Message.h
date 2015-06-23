//
//  Message.h
//  Pow Wow
//
//  Created by Will Parks on 6/23/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSAzureService.h"

@interface Message : NSObject

@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) NSInteger secondsSince;
@property (nonatomic, copy) NSDate *sentDate;

-(id)init:(NSDictionary *)message;
+(void)get:(NSString *)eventId completion:(QSCompletionBlock)completion;
-(void)save:(QSCompletionBlock)completion;

@end
