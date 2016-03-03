//
//  MFPostDetailView.m
//  Pow Wow
//
//  Created by Will Parks on 3/1/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "MFPostDetailView.h"
#import "MFPostsView.h"

@interface MFPostDetailView ()

@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIButton *upVoteButton;
@property (nonatomic, strong) UIButton *downVoteButton;
@property (nonatomic, strong) UILabel *votesLabel;
@property (nonatomic, strong) Comment *deleteComment;

@end

@implementation MFPostDetailView

-(id)init:(Post *)post
{
    self = [super init];
    if (self) {
        self.post = post;
        
        self.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [self addGestureRecognizer:recognizer];
        
        UISwipeGestureRecognizer *recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nothing:)];
        [recognizer2 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [self addGestureRecognizer:recognizer2];
        
        [self setup];
    }
    return self;
}

-(void)setup {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, wd, ht - 60)];
    self.contentView = contentView;
    [self addSubview:contentView];
    
    [MFHelpers addTitleBar:self titleText:self.post.groupName];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    [cancelButton setImage:[UIImage imageNamed:@"whitebackarrow"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    UIView *postView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, 100)];
    postView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:postView];
    
    MFProfilePicView *messagePic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(30, 22, 50, 50) facebookId:self.post.facebookId];
    [postView addSubview:messagePic];
    
    UILabel *nameMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 27, wd - 90, 20)];
    nameMessageLabel.text = self.post.name;
    [postView addSubview:nameMessageLabel];
    
    UILabel *dateMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 52, wd - 90, 20)];
    dateMessageLabel.text = [MFHelpers dateDiffBySeconds:self.post.secondsSince];
    dateMessageLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
    [postView addSubview:dateMessageLabel];
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    UIButton *upVoteButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 70, 14, 40, 40)];
    NSString *upImg = [self.post.upVotes containsObject:currentUser.userId] ? @"arrowupselected" : @"arrowup";
    [upVoteButton setImage:[UIImage imageNamed:upImg] forState:UIControlStateNormal];
    [upVoteButton addTarget:self action:@selector(upVoteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.upVoteButton = upVoteButton;
    [postView addSubview:upVoteButton];
    
    UILabel *votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(wd - 89, 34, 80, 40)];
    votesLabel.text = [NSString stringWithFormat:@"%i", self.post.votes];
    votesLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
    votesLabel.font = [UIFont boldSystemFontOfSize:24.f];
    votesLabel.textAlignment = NSTextAlignmentCenter;
    self.votesLabel = votesLabel;
    [postView addSubview:votesLabel];
    
    UIButton *downVoteButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 70, 56, 40, 40)];
    NSString *downImg = [self.post.downVotes containsObject:currentUser.userId] ? @"arrowdownselected" : @"arrowdown";
    [downVoteButton setImage:[UIImage imageNamed:downImg] forState:UIControlStateNormal];
    [downVoteButton addTarget:self action:@selector(downVoteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.downVoteButton = downVoteButton;
    [postView addSubview:downVoteButton];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 92, wd - 60, 20)];
    messageLabel.text = self.post.message;
    messageLabel.numberOfLines = 0;
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.tag = 1;
    [messageLabel sizeToFit];
    [postView addSubview:messageLabel];
    
    if(self.post.hasImage) {
        NSString *url = [NSString stringWithFormat:@"https://mayflyapp.blob.core.windows.net/posts/%@.jpeg", self.post.postId];
        UIImageView *imageView = [[UIImageView alloc] init];
        [postView addSubview:imageView];
        dispatch_queue_t queue = dispatch_queue_create("Post Image Queue", NULL);
        
        dispatch_async(queue, ^{
            NSURL *nsurl = [NSURL URLWithString:url];
            NSData *data = [NSData dataWithContentsOfURL:nsurl];
            UIImage *img = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(img == nil)
                    return;
                [imageView setImage:img];
                float imgWd = wd;
                float imgHt = (imgWd / img.size.width) * img.size.height;
                imageView.frame = CGRectMake(0, messageLabel.frame.size.height + 102, imgWd, imgHt);
                postView.frame = CGRectMake(0, 0, wd, messageLabel.frame.size.height + imageView.frame.size.height + 134);
                
                [self populateComments:postView.frame.size.height];
            });
        });

    }
    else {
        if(messageLabel.frame.size.height + 102 > postView.frame.size.height) {
            postView.frame = CGRectMake(0, 0, wd, messageLabel.frame.size.height + 128);
        }
        [self populateComments:postView.frame.size.height];
    }
}

-(void)populateComments:(int)viewY {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, viewY - 24, wd, 20)];
    NSString *commentText = self.post.comments.count == 1 ? @"1 Comment" : [NSString stringWithFormat:@"%lu Comments", (unsigned long)self.post.comments.count];
    [commentLabel setText:commentText];
    commentLabel.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
    [commentLabel setFont:[UIFont boldSystemFontOfSize:14]];
    commentLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:commentLabel];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:commentLabel.font, NSFontAttributeName, nil];
    CGFloat commentWd = [[[NSAttributedString alloc] initWithString:commentLabel.text attributes:attributes] size].width;
    
    UIImageView *commentImageView = [[UIImageView alloc] initWithFrame:CGRectMake((wd - (int)commentWd) / 2 - 18, viewY - 21, 16, 16)];
    [commentImageView setImage:[UIImage imageNamed:@"comment"]];
    [self.contentView addSubview:commentImageView];
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    if([currentUser.userId isEqualToString:self.post.userId]) {
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 24, viewY - 24, 18, 18)];
        [deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deletePostClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteButton];
    }
    
    if(self.post.comments.count > 0) {
        UIView *postBorder = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
        postBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [self.contentView addSubview:postBorder];
        viewY += 11;
    }
    
    int i = 0;
    for(Comment *comment in self.post.comments) {
        UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 130)];
        commentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:commentView];
        
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, 1)];
        topBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [commentView addSubview:topBorder];
        
        MFProfilePicView *messagePic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(30, 22, 50, 50) facebookId:comment.facebookId];
        [commentView addSubview:messagePic];
        
        UILabel *nameMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 27, wd - 90, 20)];
        nameMessageLabel.text = comment.name;
        [commentView addSubview:nameMessageLabel];
        
        UILabel *dateMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 52, wd - 90, 20)];
        dateMessageLabel.text = [MFHelpers dateDiffBySeconds:comment.secondsSince];
        dateMessageLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
        [commentView addSubview:dateMessageLabel];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 92, wd - 60, 20)];
        messageLabel.text = comment.message;
        messageLabel.numberOfLines = 0;
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.tag = 1;
        [messageLabel sizeToFit];
        [commentView addSubview:messageLabel];
        
        if(messageLabel.frame.size.height + 102 > commentView.frame.size.height) {
            commentView.frame = CGRectMake(0, viewY, wd, messageLabel.frame.size.height + 112);
        }
        
        if([currentUser.userId isEqualToString:comment.userId]) {
            UIButton *deleteCommentButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 24, commentView.frame.size.height - 24, 18, 18)];
            [deleteCommentButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
            [deleteCommentButton addTarget:self action:@selector(deleteCommentClick:) forControlEvents:UIControlEventTouchUpInside];
            deleteCommentButton.tag = i;
            [commentView addSubview:deleteCommentButton];
        }
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, commentView.frame.size.height - 1, wd, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [commentView addSubview:bottomBorder];
        
        viewY += commentView.frame.size.height;
        i++;
    }
    
    UIView *commentBottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
    commentBottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [self.contentView addSubview:commentBottomBorder];
    viewY += 1;
    
    UIView *commentMiddle = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 10)];
    commentMiddle.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [self.contentView addSubview:commentMiddle];
    viewY += 11;
    
    UIButton *postMessageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, viewY, wd, 70)];
    [postMessageButton addTarget:self action:@selector(postMessageClick:) forControlEvents:UIControlEventTouchUpInside];
    postMessageButton.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:postMessageButton];
    
    MFProfilePicView *postMessagePic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(30, 10, 50, 50) facebookId:currentUser.facebookId];
    [postMessageButton addSubview:postMessagePic];
    
    UILabel *postMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 25, wd - 90, 20)];
    postMessageLabel.text = @"Add Comment...";
    postMessageLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
    [postMessageButton addSubview:postMessageLabel];
    
    UIView *postTopBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, 1)];
    postTopBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [postMessageButton addSubview:postTopBorder];
    
    UIView *postBottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 70, wd, 1)];
    postBottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [postMessageButton addSubview:postBottomBorder];
    viewY += 70;
    
    self.contentView.contentSize = CGSizeMake(wd, viewY + 60);
}

-(void)upVoteButtonClick:(id)sender {
    Post *post = self.post;
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    if([post.upVotes containsObject:currentUser.userId]) {
        [post.upVotes removeObject:currentUser.userId];
    }
    else {
        [post.upVotes addObject:currentUser.userId];
    }
    if([post.downVotes containsObject:currentUser.userId]) {
        [post.downVotes removeObject:currentUser.userId];
    }
    
    [self updateVote];
}

-(void)downVoteButtonClick:(id)sender {
    Post *post = self.post;
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    if([post.upVotes containsObject:currentUser.userId]) {
        [post.upVotes removeObject:currentUser.userId];
    }
    if([post.downVotes containsObject:currentUser.userId]) {
        [post.downVotes removeObject:currentUser.userId];
    }
    else {
        [post .downVotes addObject:currentUser.userId];
    }
    
    [self updateVote];
}

-(void)updateVote {
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    
    NSString *upImg = [self.post.upVotes containsObject:currentUser.userId] ? @"arrowupselected" : @"arrowup";
    [self.upVoteButton setImage:[UIImage imageNamed:upImg] forState:UIControlStateNormal];
    
    NSString *downImg = [self.post.downVotes containsObject:currentUser.userId] ? @"arrowdownselected" : @"arrowdown";
    [self.downVoteButton setImage:[UIImage imageNamed:downImg] forState:UIControlStateNormal];
    
    self.post.votes = (int)self.post.upVotes.count - (int)self.post.downVotes.count;
    self.votesLabel.text = [NSString stringWithFormat:@"%i", self.post.votes];
    
    [self.post save:^(Post *post) {
        for(UIView *subview in self.superview.subviews) {
            if([subview isMemberOfClass:[MFPostsView class]]) {
                MFPostsView *postsView = (MFPostsView *)subview;
                [postsView loadPosts];
            }
        }
    }];
}

-(void)postMessageClick:(id)sender {
    MFCreateCommentView *view = [[MFCreateCommentView alloc] init:self.post];
    [MFHelpers open:view onView:self.superview];
}

-(void)deletePostClick:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Post"
                                                    message:@"Are you sure you want to delete this post?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

-(void)deleteCommentClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    self.deleteComment = self.post.comments[button.tag];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Comment"
                                                    message:@"Are you sure you want to delete this comment?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            break;
        case 1: //"Yes" pressed
            [self delete];
            break;
    }
}

-(void)delete {
    
    if(self.deleteComment == nil || self.deleteComment.commentId == nil) {
        [MFHelpers showDisableView:self];
        [self.post deletePost:^(NSDictionary *item) {
            if([self.superview isMemberOfClass:[MFView class]])
            {
                MFView *view = (MFView *)self.superview;
                [view refresh];
            }
            
            [self cancelButtonClick:nil];
        }];
    }
    else {
        NSMutableArray *comments = [[NSMutableArray alloc] init];
        for(Comment *comment in self.post.comments) {
            if(![comment.commentId isEqualToString:self.deleteComment.commentId]) {
                [comments addObject:comment];
            }
        }
        self.post.comments = comments;
        [self setup];
        
        [self.deleteComment deleteComment:^(NSDictionary *item) {
            if([self.superview isMemberOfClass:[MFView class]])
            {
                MFView *view = (MFView *)self.superview;
                [view refresh];
            }
        }];
    }
}

-(void)cancelButtonClick:(id)sender
{
    [MFHelpers closeRight:self];
}

-(void)nothing:(id)sender {
    
}

@end
