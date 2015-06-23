//
//  QSAzureMessageService.h
//  Pow Wow
//
//  Created by Will Parks on 6/22/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

#define API_VERSION @"?api-version=2015-01"
#define HUBFULLACCESS @"Endpoint=sb://mayflyapphub-ns.servicebus.windows.net/;SharedAccessKeyName=DefaultFullSharedAccessSignature;SharedAccessKey=Xx0XVX29Gb0hPyBsoB7BYD0SUPiNYSQAB21Y115OXME="
#define HUBNAME @"mayflyapphub"

@interface QSAzureMessageService : NSObject

-(void)send:(NSString *)deviceToken alert:(NSString *)alert message:(NSString *)message;

@end
