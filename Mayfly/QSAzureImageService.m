//
//  QSAzureImageService.m
//  Pow Wow
//
//  Created by Will Parks on 2/12/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "QSAzureImageService.h"


@implementation QSAzureImageService

+(void)uploadImage:(NSString *)container image:(UIImage *)image name:(NSString *)name completionHandler:(void(^)(NSURL *url))completionHandler {
    // Get the image data (JPEG)
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    
    // Create the blob name (*.jpeg)
    NSString *blobName = [NSString stringWithFormat:@"%@.jpeg", name];
    
    // Init storage account
    AZSCloudStorageAccount *storageAccount = [AZSCloudStorageAccount accountFromConnectionString:AZURE_STORAGE_CONNECTION_STRING];
    
    // Init blob client
    AZSCloudBlobClient *blobClient = [storageAccount getBlobClient];
    
    // Get a reference to a container
    AZSCloudBlobContainer *blobContainer = [blobClient containerReferenceFromName:container];
    
    // Ensure that the container exists
    [blobContainer createContainerWithAccessType:AZSContainerPublicAccessTypeBlob
                                  requestOptions:[blobClient defaultRequestOptions] operationContext:nil completionHandler:^(NSError * _Nullable createError) {
                                      
                                      // Validate response
                                      if (createError != nil) {
                                          NSString *errorCode= [createError.userInfo valueForKey:@"Code"];
                                          
                                          // Unless it was a ContainerAlreadyExists error - return
                                          if (![errorCode isEqualToString:@"ContainerAlreadyExists"]) {
                                              NSLog(@"Error: %@", errorCode);
                                              return;
                                          }
                                      }
                                      
                                      // Get the block blob reference
                                      AZSCloudBlockBlob *blob = [blobContainer blockBlobReferenceFromName:blobName];
                                      
                                      // Upload data
                                      [blob uploadFromData:data completionHandler:^(NSError * _Nullable uploadError) {
                                          // Call the callback
                                          completionHandler(uploadError == nil
                                                            ? blob.storageUri.primaryUri
                                                            : nil);
                                      }];
                                  }];
}

//
//+(void)uploadImage:(NSString *)containerName image:(UIImage *)image imageName:(NSString *)imageName
//{
//    // Create a semaphore to prevent the method from exiting before all of the async operations finish.
//    // In most real applications, you wouldn't do this, it makes this whole series of operations synchronous.
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    
//    // Create a storage account object from a connection string.
//    AZSCloudStorageAccount *account = [AZSCloudStorageAccount accountFromConnectionString:@"DefaultEndpointsProtocol=https://mayflyapp.blob.core.windows.net/;AccountName=mayflyapp;AccountKey=XBvMbjU3maNmSetq/xF3nXxmVG93RVio8MoI4lzYQIab5EfB1aapemG15Q06kGxSnIpWQIPWiTR3vOdkkJsLgw=="];
//    
//    // Create a blob service client object.
//    AZSCloudBlobClient *blobClient = [account getBlobClient];
//    
//    // Create a local container object with a unique name.
//    //NSString *containerName = @"messages";
//    AZSCloudBlobContainer *blobContainer = [blobClient containerReferenceFromName:containerName];
//    
//    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
//    
//    
//    // Create the container on the service and check to see if there was an error.
////    [blobContainer createContainerWithCompletionHandler:^(NSError* error){
////        if (error != nil){
////            NSLog(@"Error in creating container.");
////        }
//    
//        // Create a local blob object
//        //AZSCloudBlockBlob *blockBlob = [blobContainer blockBlobReferenceFromName:@"blockBlob"];
//        
//        // Get some sample text for the blob
//        //NSString *blobText = @"Sample blob text";
//        
//        // Upload the text to the blob.
//        [blockBlob uploadFromText:blobText completionHandler:^(NSError *error) {
//            if (error != nil){
//                NSLog(@"Error in uploading blob.");
//            }
//            
//            // Download the blob's contents to a new text string.
//            [blockBlob downloadToTextWithCompletionHandler:^(NSError *error, NSString *resultText) {
//                if (error != nil){
//                    NSLog(@"Error in downloading blob.");
//                }
//                
//                // Validate that the uploaded/downloaded string is correct.
//                if (![blobText isEqualToString:resultText])
//                {
//                    NSLog(@"Error - the text in the blob does not match.");
//                }
//                
//                // Delete the container from the service.
////                [blobContainer deleteContainerWithCompletionHandler:^(NSError* error){
////                    if (error != nil){
////                        NSLog(@"Error in deleting container.");
////                    }
////                    
////                    dispatch_semaphore_signal(semaphore);
////                }];
//            }];
//        }];
// //   }];
//    
//    // Pause the method until the above operations complete.
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//}

@end
