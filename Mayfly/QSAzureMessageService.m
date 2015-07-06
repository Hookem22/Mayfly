//
//  QSAzureMessageService.m
//  Pow Wow
//
//  Created by Will Parks on 6/22/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "QSAzureMessageService.h"

@implementation QSAzureMessageService

NSString *HubEndpoint;
NSString *HubSasKeyName;
NSString *HubSasKeyValue;

-(id)init
{
    self = [super init];
    
    if (self)
    {
        [self ParseConnectionString];
    }
    
    return self;
}

-(void)send:(NSString *)deviceToken alert:(NSString *)alert message:(NSString *)message
{
    [self SendNotificationRESTAPI:deviceToken alert:alert message:message];
}

-(void)SendNotificationRESTAPI:(NSString *)deviceToken alert:(NSString *)alert message:(NSString *)message
{
    NSURLSession* session = [NSURLSession
                             sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                             delegate:nil delegateQueue:nil];
    
    // Apple Notification format of the notification message
    NSString *json = [NSString stringWithFormat:@"{\"aps\":{\"badge\":1,\"alert\":\"%@\",\"message\":\"%@\"}}",
                      alert, message];
    
    // Construct the messages REST endpoint
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/messages/%@", HubEndpoint,
                                       HUBNAME, API_VERSION]];
    
    // Generated the token to be used in the authorization header.
    NSString* authorizationToken = [self generateSasToken:[url absoluteString]];
    
    //Create the request to add the APNS notification message to the hub
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // Signify apple notification format
    [request setValue:@"apple" forHTTPHeaderField:@"ServiceBusNotification-Format"];
    
    //Authenticate the notification message POST request with the SaS token
    [request setValue:authorizationToken forHTTPHeaderField:@"Authorization"];
    
    //Send to Tag
    NSString *tag = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    [request setValue:tag forHTTPHeaderField:@"ServiceBusNotification-Tags"];
    
    //Add the notification message body
    [request setHTTPBody:[json dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Send the REST request
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) response;
                                          if (error || httpResponse.statusCode != 200)
                                          {
                                              NSLog(@"\nError status: %ld\nError: %@", (long)httpResponse.statusCode, error);
                                          }
                                          if (data != NULL)
                                          {
                                              /*xmlParser = [[NSXMLParser alloc] initWithData:data];
                                               [xmlParser setDelegate:self];
                                               [xmlParser parse];*/
                                          }
                                      }];
    [dataTask resume];
}

-(void)ParseConnectionString
{
    NSArray *parts = [HUBFULLACCESS componentsSeparatedByString:@";"];
    NSString *part;
    
    if ([parts count] != 3)
    {
        NSException* parseException = [NSException exceptionWithName:@"ConnectionStringParseException"
                                                              reason:@"Invalid full shared access connection string" userInfo:nil];
        
        @throw parseException;
    }
    
    for (part in parts)
    {
        if ([part hasPrefix:@"Endpoint"])
        {
            HubEndpoint = [NSString stringWithFormat:@"https%@",[part substringFromIndex:11]];
        }
        else if ([part hasPrefix:@"SharedAccessKeyName"])
        {
            HubSasKeyName = [part substringFromIndex:20];
        }
        else if ([part hasPrefix:@"SharedAccessKey"])
        {
            HubSasKeyValue = [part substringFromIndex:16];
        }
    }
}

-(NSString *)CF_URLEncodedString:(NSString *)inputString
{
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)inputString,
                                                                        NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}


-(NSString*) generateSasToken:(NSString*)uri
{
    NSString *targetUri;
    NSString* utf8LowercasedUri = NULL;
    NSString *signature = NULL;
    NSString *token = NULL;
    
    @try
    {
        // Add expiration
        uri = [uri lowercaseString];
        utf8LowercasedUri = [self CF_URLEncodedString:uri];
        targetUri = [utf8LowercasedUri lowercaseString];
        NSTimeInterval expiresOnDate = [[NSDate date] timeIntervalSince1970];
        int expiresInMins = 60; // 1 hour
        expiresOnDate += expiresInMins * 60;
        UInt64 expires = trunc(expiresOnDate);
        NSString* toSign = [NSString stringWithFormat:@"%@\n%qu", targetUri, expires];
        
        // Get an hmac_sha1 Mac instance and initialize with the signing key
        const char *cKey  = [HubSasKeyValue cStringUsingEncoding:NSUTF8StringEncoding];
        const char *cData = [toSign cStringUsingEncoding:NSUTF8StringEncoding];
        unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
        CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
        NSData *rawHmac = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
        signature = [self CF_URLEncodedString:[rawHmac base64EncodedStringWithOptions:0]];
        
        // construct authorization token string
        token = [NSString stringWithFormat:@"SharedAccessSignature sr=%@&sig=%@&se=%qu&skn=%@",
                 targetUri, signature, expires, HubSasKeyName];
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@", [NSString stringWithFormat:@"Exception Generating SaS Token: %@", exception.reason]);
    }
    @finally
    {
        if (utf8LowercasedUri != NULL)
            CFRelease((CFStringRef)utf8LowercasedUri);
        if (signature != NULL)
            CFRelease((CFStringRef)signature);
    }
    
    return token;
}




@end
