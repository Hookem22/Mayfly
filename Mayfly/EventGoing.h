//
//  EventGoing.h
//  Pow Wow
//
//  Created by Will Parks on 12/17/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSAzureService.h"

@interface EventGoing : NSObject

@property (nonatomic, copy) NSString *eventGoingId;
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, assign) BOOL isMuted;

-(id)init:(NSDictionary *)dict;
+(void)getByEventId:(NSString *)eventId completion:(QSCompletionBlock)completion;
+(void)joinEvent:(NSString *)eventId userId:(NSString *)userId isAdmin:(BOOL)isAdmin completion:(QSCompletionBlock)completion;
-(void)save:(QSCompletionBlock)completion;

@end
