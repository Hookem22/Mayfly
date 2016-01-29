// ----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// ----------------------------------------------------------------------------
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "QSAzureService.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>


#pragma mark * Private interace


@interface QSAzureService() <MSFilter>

@property (nonatomic, strong)   MSTable *table;
@property (nonatomic)           NSInteger busyCount;

@end


#pragma mark * Implementation


@implementation QSAzureService

@synthesize items;


+ (QSAzureService *)defaultService:(NSString *)tableName
{
    /*
    // Create a singleton instance of QSAzureService
    static QSAzureService* service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[QSAzureService alloc] init:tableName];
    });
    */
    
    QSAzureService *service = [[QSAzureService alloc] init:tableName];
    
    return service;
}

-(QSAzureService *)init:(NSString *)tableName
{
    self = [super init];
    
    if (self)
    {
        // Initialize the Mobile Service client with your URL and key
        MSClient *client = [MSClient clientWithApplicationURLString:@"https://mayflyapp.azure-mobile.net/"
                                                     applicationKey:@"NzEvHltvEcuInDmQsnXqReEIitsWIa99"];
        
        // Add a Mobile Service filter to enable the busy indicator
        self.client = [client clientWithFilter:self];
        
        // Create an MSTable instance to allow us to work with the Item table
        self.table = [_client tableWithName:tableName];
        
        self.items = [[NSMutableArray alloc] init];
        self.busyCount = 0;
    }
    
    return self;
}

-(void)get:(id)itemId completion:(QSCompletionBlock)completion
{
    [self.table readWithId:itemId completion:^(NSDictionary *item, NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         items = [item mutableCopy];
         
         // Let the caller know that we finished
         completion(items);
     }];
}

-(void)get:(QSCompletionBlock)completion
{
    [self.table readWithCompletion:^(NSArray *results, NSInteger totalCount, NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         items = [results mutableCopy];
         
         // Let the caller know that we finished
         completion(items);
     }];
}

- (void)getByWhere:(NSString *)whereStatement completion:(QSCompletionBlock)completion
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:whereStatement];
    
    [self.table readWithPredicate:predicate completion:^(NSArray *results, NSInteger totalCount, NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         items = [results mutableCopy];
         
         // Let the caller know that we finished
         completion(results);
     }];
    
}

- (void)getByProc:(NSString *)procName params:(NSDictionary *)params completion:(QSCompletionBlock)completion
{
    [self.client invokeAPI:procName body:params HTTPMethod:@"POST" parameters:nil
                   headers:nil completion:^(NSArray *results, NSHTTPURLResponse *response, NSError *error) {
                       [self logErrorIfNotNil:error];
                       //NSLog(@"%@", results);
                       items = [results mutableCopy];
                       
                       completion(items);
                   }];
}


-(void)addItem:(NSDictionary *)item completion:(QSCompletionBlock)completion
{
    // Insert the item into the TodoItem table and add to the items array on completion
    [self.table insert:item completion:^(NSDictionary *result, NSError *error)
    {
        [self logErrorIfNotNil:error];
        
        // Let the caller know that we finished
        completion(result);
    }];
}

-(void)updateItem:(NSDictionary *)item completion:(QSCompletionBlock)completion
{
    [self.table update:item completion:^(NSDictionary *result, NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         // Let the caller know that we finished
         completion(result);
     }];
}

-(void)deleteItem:(id)itemId completion:(QSCompletionBlock)completion
{
    [self.table deleteWithId:itemId completion:^(id itemId, NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         // Let the caller know that we finished
         completion(itemId);
     }];
}

- (void)busy:(BOOL)busy
{
    // assumes always executes on UI thread
    if (busy)
    {
        if (self.busyCount == 0 && self.busyUpdate != nil)
        {
            self.busyUpdate(YES);
        }
        self.busyCount ++;
    }
    else
    {
        if (self.busyCount == 1 && self.busyUpdate != nil)
        {
            self.busyUpdate(FALSE);
        }
        self.busyCount--;
    }
}

- (void)logErrorIfNotNil:(NSError *) error
{
    if (error)
    {
        NSLog(@"ERROR %@", error);
    }
}


#pragma mark * MSFilter methods


- (void)handleRequest:(NSURLRequest *)request
                 next:(MSFilterNextBlock)next
             response:(MSFilterResponseBlock)response
{
    // A wrapped response block that decrements the busy counter
    MSFilterResponseBlock wrappedResponse = ^(NSHTTPURLResponse *innerResponse, NSData *data, NSError *error)
    {
        [self busy:NO];
        response(innerResponse, data, error);
    };
    
    // Increment the busy counter before sending the request
    [self busy:YES];
    next(request, wrappedResponse);
}

@end
