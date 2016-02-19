//
//  QSAzureImageService.h
//  Pow Wow
//
//  Created by Will Parks on 2/12/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Azure_Storage_Client_Library.h"

#define AZURE_STORAGE_CONNECTION_STRING @"DefaultEndpointsProtocol=https://mayflyapp.blob.core.windows.net/;AccountName=mayflyapp;AccountKey=XBvMbjU3maNmSetq/xF3nXxmVG93RVio8MoI4lzYQIab5EfB1aapemG15Q06kGxSnIpWQIPWiTR3vOdkkJsLgw=="

@interface QSAzureImageService : NSObject

+(void)uploadImage:(NSString *)container image:(UIImage *)image name:(NSString *)name completionHandler:(void(^)(NSURL *url))completionHandler;

@end
