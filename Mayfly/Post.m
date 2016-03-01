//
//  Message.m
//  Pow Wow
//
//  Created by Will Parks on 6/23/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "Post.h"

@implementation Post

@synthesize postId = _postId;
@synthesize userId = _userId;
@synthesize facebookId = _facebookId;
@synthesize name = _name;
@synthesize message = _message;
@synthesize schoolId = _schoolId;
@synthesize secondsSince = _secondsSince;
@synthesize sentDate = _sentDate;
@synthesize hasImage = _hasImage;
@synthesize upVotes = _upVotes;
@synthesize downVotes = _downVotes;
@synthesize votes = _votes;

-(id)init:(NSDictionary *)post
{
    self = [super init];
    if (self) {
        self.postId = [post valueForKey:@"id"];
        self.userId = [post objectForKey:@"userid"];
        self.facebookId = [post objectForKey:@"facebookid"];
        self.name = [post objectForKey:@"name"];
        self.message = [post objectForKey:@"message"];
        self.schoolId = [post objectForKey:@"schoolid"];
        self.secondsSince = [[post objectForKey:@"Seconds"] isMemberOfClass:[NSNull class]] ? 0 : [[post objectForKey:@"Seconds"] intValue];
        self.sentDate = [post objectForKey:@"__createdAt"];
        self.hasImage = [[post objectForKey:@"hasimage"] isMemberOfClass:[NSNull class]] ? NO : [[post objectForKey:@"hasimage"] boolValue];
        
        //Init up votes and down votes
        NSString *up = [[post objectForKey:@"upvotes"] isMemberOfClass:[NSNull class]] ? @"" : [post objectForKey:@"upvotes"];
        self.upVotes = [[up componentsSeparatedByString: @"|"] mutableCopy];
        NSString *down = [[post objectForKey:@"downvotes"] isMemberOfClass:[NSNull class]] ? @"" : [post objectForKey:@"downvotes"];
        self.downVotes = [[down componentsSeparatedByString: @"|"] mutableCopy];
        
        self.votes = (int)self.upVotes.count - (int)self.downVotes.count;
    }
    return self;
}

+(void)get:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Post"];
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:school.schoolId forKey:@"schoolid"];
    
    [service getByProc:@"getposts" params:params completion:^(NSArray *results) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(id item in results) {
            Post *post = [[Post alloc] init:item];
            [array addObject:post];
        }
        [array sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"votes" ascending:NO]]];
        completion(array);
    }];
}


-(void)save:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Post"];
    
    NSDictionary *dict = @{@"userid":self.userId, @"facebookid":self.facebookId, @"name": self.name, @"message": self.message, @"schoolid": self.schoolId, @"hasimage": [NSNumber numberWithBool:self.hasImage], @"upvotes":[self listToString:self.upVotes], @"downvotes":[self listToString:self.downVotes] };
    
    if([self.postId length] > 0) { //Update
        NSMutableDictionary *mutableEvent = [dict mutableCopy];
        [mutableEvent setObject:self.postId forKey:@"id"];
        [service updateItem:mutableEvent completion:^(NSDictionary *item)
         {
             completion(self);
         }];
    }
    else //Add
    {
        [service addItem:dict completion:^(NSDictionary *item)
         {
             self.postId = [item objectForKey:@"id"];
             completion(self);
         }];
    }
}

-(void)addImage:(UIImage *)image completion:(QSCompletionBlock)completion {
    [QSAzureImageService uploadImage:@"posts" image:image name:self.postId completionHandler:^(NSURL *url) {
        completion([NSString stringWithFormat:@"%@", url]);
    }];
}

-(NSString *)listToString:(NSMutableArray *)list
{
    NSString *string = @"";
    for(int i = 0; i < [list count]; i++)
    {
        if(i > 0)
            string = [NSString stringWithFormat:@"%@|", string];
        
        NSString *item = (NSString *)[list objectAtIndex:i];
        string = [NSString stringWithFormat:@"%@%@", string, item];
    }
    return string;
}

@end
