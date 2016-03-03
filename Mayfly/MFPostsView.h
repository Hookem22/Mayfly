//
//  MFPostsView.h
//  Pow Wow
//
//  Created by Will Parks on 2/29/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFView.h"
#import "MFPostDetailView.h"
#import "MFHelpers.h"
#import "MFProfilePicView.h"
#import "Post.h"

@interface MFPostsView : UIScrollView <UIScrollViewDelegate>

-(void)addPost:(Post *)post;
-(void)loadPosts;
-(void)populateAll;
-(void)populateMyInterests;
-(void)goToPost:(NSString *)postId;

@end
