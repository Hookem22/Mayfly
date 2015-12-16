//
//  School.h
//  Pow Wow
//
//  Created by Will Parks on 12/15/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSAzureService.h"

@interface School : NSObject

@property (nonatomic, copy) NSString *schoolId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

-(id)init:(NSDictionary *)school;
+(void)get:(double)latitude longitdue:(double)longitude completion:(QSCompletionBlock)completion;

@end
