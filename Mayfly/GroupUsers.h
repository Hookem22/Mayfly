//
//  GroupUsers.h
//  Pow Wow
//
//  Created by Will Parks on 12/29/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSAzureService.h"

@interface GroupUsers : NSObject

@property (nonatomic, copy) NSString *groupUserId;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *facebookId;

+(void)getByGroupId:(NSString *)groupId completion:(QSCompletionBlock)completion;
+(void)getByUserId:(NSString *)userId completion:(QSCompletionBlock)completion;
+(void)joinGroup:(NSString *)groupId userId:(NSString *)userId isAdmin:(BOOL)isAdmin;


@end
