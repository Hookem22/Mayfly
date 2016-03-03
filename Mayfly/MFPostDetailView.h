//
//  MFPostDetailView.h
//  Pow Wow
//
//  Created by Will Parks on 3/1/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "MFProfilePicView.h"
#import "MFCreateCommentView.h"
#import "MFHelpers.h"

@interface MFPostDetailView : UIView

-(id)init:(Post *)post;
-(void)setup;

@end
