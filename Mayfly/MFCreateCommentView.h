//
//  MFCreateCommentView.h
//  Pow Wow
//
//  Created by Will Parks on 3/2/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFProfilePicView.h"
#import "MFHelpers.h"
#import "Post.h"
#import "Comment.h"

@interface MFCreateCommentView : UIView

-(id)init:(Post *)post;

@end
