//
//  Comment.m
//  Pow Wow
//
//  Created by Will Parks on 3/2/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "Comment.h"

@implementation Comment

@synthesize commentId = _commentId;
@synthesize postId = _postId;
@synthesize userId = _userId;
@synthesize facebookId = _facebookId;
@synthesize name = _name;
@synthesize message = _message;
@synthesize secondsSince = _secondsSince;
@synthesize sentDate = _sentDate;
@synthesize hasImage = _hasImage;

-(id)init:(NSDictionary *)comment
{
    self = [super init];
    if (self) {
        self.commentId = [comment valueForKey:@"id"];
        self.postId = [comment valueForKey:@"postid"];
        self.userId = [comment objectForKey:@"userid"];
        self.facebookId = [comment objectForKey:@"facebookid"];
        self.name = [comment objectForKey:@"name"];
        self.message = [comment objectForKey:@"message"];
        self.secondsSince = [[comment objectForKey:@"Seconds"] isMemberOfClass:[NSNull class]] ? 0 : [[comment objectForKey:@"Seconds"] intValue];
        self.sentDate = [comment objectForKey:@"__createdAt"];
        self.hasImage = [[comment objectForKey:@"hasimage"] isMemberOfClass:[NSNull class]] ? NO : [[comment objectForKey:@"hasimage"] boolValue];

    }
    return self;
}

+(void)get:(NSString *)postId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Comment"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:postId forKey:@"postid"];
    
    [service getByProc:@"getcomments" params:params completion:^(NSArray *results) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(id item in results) {
            Comment *comment = [[Comment alloc] init:item];
            [array addObject:comment];
        }
        completion(array);
    }];
}


-(void)save:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Comment"];
    
    NSDictionary *dict = @{@"postid":self.postId, @"userid":self.userId, @"facebookid":self.facebookId, @"name": self.name, @"message": self.message, @"hasimage": [NSNumber numberWithBool:self.hasImage] };
    
    if([self.commentId length] > 0) { //Update
        NSMutableDictionary *mutableEvent = [dict mutableCopy];
        [mutableEvent setObject:self.commentId forKey:@"id"];
        [service updateItem:mutableEvent completion:^(NSDictionary *item)
         {
             completion(self);
         }];
    }
    else //Add
    {
        [service addItem:dict completion:^(NSDictionary *item)
         {
             self.commentId = [item objectForKey:@"id"];
             completion(self);
         }];
    }
}

-(void)deleteComment:(QSCompletionBlock)completion {
    QSAzureService *service = [QSAzureService defaultService:@"Comment"];
    [service deleteItem:self.commentId completion:^(NSDictionary *item)
     {
         completion(item);
     }];
}

@end
