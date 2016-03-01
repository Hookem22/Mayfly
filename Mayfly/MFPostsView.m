//
//  MFPostsView.m
//  Pow Wow
//
//  Created by Will Parks on 2/29/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "MFPostsView.h"

@interface MFPostsView ()

@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) NSMutableDictionary *postImageViews;
@property (nonatomic, strong) NSMutableArray *arrowUpButtons;
@property (nonatomic, strong) NSMutableArray *arrowDownButtons;
@property (nonatomic, strong) NSMutableArray *votesLabels;
@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation MFPostsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        self.delegate = self;
        
    }
    return self;
}

-(void)loadPosts
{
    [Post get:^(NSArray *posts)
     {
         self.posts = posts;
         [self populate];
         [self loadMessageImages];
         
         [MFHelpers hideProgressView:self.superview];
     }];
}

-(void)addPost:(Post *)post {
    NSMutableArray *posts = [[NSMutableArray alloc] init];
    [posts addObject:post];
    for(Post *item in self.posts)
        [posts addObject:item];
    
    self.posts = posts;
    [self populate];
    [self loadMessageImages];
}

-(void)loadMessageImages {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    self.postImageViews = [[NSMutableDictionary alloc] init];
    
    for(Post *post in self.posts) {
        if(post.hasImage) {
            NSString *url = [NSString stringWithFormat:@"https://mayflyapp.blob.core.windows.net/posts/%@.jpeg", post.postId];
            UIImageView *imageView = [[UIImageView alloc] init];
            dispatch_queue_t queue = dispatch_queue_create("Post Image Queue", NULL);
            
            dispatch_async(queue, ^{
                NSURL *nsurl = [NSURL URLWithString:url];
                NSData *data = [NSData dataWithContentsOfURL:nsurl];
                UIImage *img = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(img == nil)
                        return;
                    [imageView setImage:img];
                    float imgWd = wd - 60;
                    float imgHt = (imgWd / img.size.width) * img.size.height;
                    imageView.frame = CGRectMake(30, 0, imgWd, imgHt);
                    [self.postImageViews setObject:imageView forKey:post.postId];
                    [self refreshImages];
                });
            });
        }
    }
}

-(void)populate {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    
    self.arrowUpButtons = [[NSMutableArray alloc] init];
    self.arrowDownButtons = [[NSMutableArray alloc] init];
    self.votesLabels = [[NSMutableArray alloc] init];
    
    for(UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    int viewY = 0;
    int tag = 0;
    for(Post *post in self.posts) {
        UIView *postView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 120)];
        postView.backgroundColor = [UIColor whiteColor];
        [self addSubview:postView];
        
        
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, 1)];
        if(viewY > 0) {
            topBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        } else {
            topBorder.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        }
        [postView addSubview:topBorder];

        UIView *middle = [[UIView alloc] initWithFrame:CGRectMake(0, 1, wd, 10)];
        middle.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        [postView addSubview:middle];
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 11, wd, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [postView addSubview:bottomBorder];
        
        MFProfilePicView *messagePic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(30, 22, 50, 50) facebookId:post.facebookId];
        [postView addSubview:messagePic];
        
        UILabel *nameMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 27, wd - 90, 20)];
        nameMessageLabel.text = post.name;
        [postView addSubview:nameMessageLabel];
        
        UILabel *dateMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 52, wd - 90, 20)];
        dateMessageLabel.text = [MFHelpers dateDiffBySeconds:post.secondsSince];
        dateMessageLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
        [postView addSubview:dateMessageLabel];
        
        UIButton *upVoteButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 70, 15, 40, 40)];
        NSString *upImg = [post.upVotes containsObject:currentUser.userId] ? @"arrowupselected" : @"arrowup";
        [upVoteButton setImage:[UIImage imageNamed:upImg] forState:UIControlStateNormal];
        [upVoteButton addTarget:self action:@selector(upVoteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        upVoteButton.tag = tag;
        [self.arrowUpButtons addObject:upVoteButton];
        [postView addSubview:upVoteButton];
        
        UILabel *votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(wd - 89, 38, 80, 40)];
        votesLabel.text = [NSString stringWithFormat:@"%i", post.votes];
        votesLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
        votesLabel.font = [UIFont boldSystemFontOfSize:24.f];
        votesLabel.textAlignment = NSTextAlignmentCenter;
        [self.votesLabels addObject:votesLabel];
        [postView addSubview:votesLabel];
        
        UIButton *downVoteButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 70, 64, 40, 40)];
        NSString *downImg = [post.downVotes containsObject:currentUser.userId] ? @"arrowdownselected" : @"arrowdown";
        [downVoteButton setImage:[UIImage imageNamed:downImg] forState:UIControlStateNormal];
        [downVoteButton addTarget:self action:@selector(downVoteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        downVoteButton.tag = tag;
        [self.arrowDownButtons addObject:downVoteButton];
        [postView addSubview:downVoteButton];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 92, wd - 60, 20)];
        messageLabel.text = post.message;
        messageLabel.numberOfLines = 0;
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.tag = 1;
        [messageLabel sizeToFit];
        [postView addSubview:messageLabel];
        
        int imgHt = 0;
        if(post.hasImage) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(60, messageLabel.frame.size.height + 102, 80, 80);
            //[imageView setImage:[UIImage imageNamed:@"portrait"]];
            [postView addSubview:imageView];
            imageView.tag = 2;
            imgHt = imageView.frame.size.height + 10;
        }
        
        if(messageLabel.frame.size.height + imgHt + 102 > postView.frame.size.height) {
            postView.frame = CGRectMake(0, viewY, wd, messageLabel.frame.size.height + imgHt + 112);
        }
        //Bottom border
        Post *lastPost = self.posts[self.posts.count - 1];
        if([post.postId isEqualToString:lastPost.postId] && !post.hasImage) {
            UIView *topBorder2 = [[UIView alloc] initWithFrame:CGRectMake(0, postView.frame.size.height, wd, 1)];
            topBorder2.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
            [postView addSubview:topBorder2];
            
            UIView *middle2 = [[UIView alloc] initWithFrame:CGRectMake(0, postView.frame.size.height + 1, wd, 300)];
            middle2.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
            [postView addSubview:middle2];
            postView.frame = CGRectMake(postView.frame.origin.x, postView.frame.origin.y, postView.frame.size.width, postView.frame.size.height + 80);
        }
        
        viewY += postView.frame.size.height;
        tag++;
    }
    
    self.contentSize = CGSizeMake(wd, viewY);
    //self.frame = CGRectMake(0, self.frame.origin.y, self.frame.size.width, viewY);
}

-(void)refreshImages {
    int viewY = 0;
    int i = 0;
    for(UIView *postView in self.subviews) {
        Post *post = self.posts[i];
        postView.frame = CGRectMake(0, viewY, postView.frame.size.width, postView.frame.size.height);
        if(post.hasImage) {
            int messageLabelHt = 0;
            for(UIView *subview in postView.subviews) {
                if(subview.tag == 1) {
                    messageLabelHt = subview.frame.size.height;
                }
            }
            int imgHt = 0;
            for(UIView *subview in postView.subviews) {
                if ([subview isMemberOfClass:[UIImageView class]] && subview.tag == 2) {
                    UIImageView *imageView = (UIImageView *)subview;
                    UIImageView *imageViewWithPic = (UIImageView *)[self.postImageViews objectForKey:post.postId];
                    if(imageViewWithPic != nil) {
                        [imageView setImage:imageViewWithPic.image];
                        imageView.frame = CGRectMake(30, messageLabelHt + 102, imageViewWithPic.frame.size.width, imageViewWithPic.frame.size.height);
                        
                        imgHt = imageView.frame.size.height + 20;
                    }
                }
            }
            
            if(messageLabelHt + imgHt + 102 > postView.frame.size.height) {
                postView.frame = CGRectMake(0, viewY, postView.frame.size.width, messageLabelHt + imgHt + 112);
            }
        }
        viewY += postView.frame.size.height;
        i++;
    }
    
    self.contentSize = CGSizeMake(self.frame.size.width, viewY);
    //self.messagesView.frame = CGRectMake(0, self.messagesView.frame.origin.y, self.messagesView.frame.size.width, viewY);
}

-(void)upVoteButtonClick:(id)sender {
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] init];
        [MFHelpers open:loginView onView:self.superview];
        return;
    }
    
    UIButton *button = (UIButton *)sender;
    Post *post = self.posts[button.tag];
    
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
    
    UIButton *upButton = (UIButton *)self.arrowUpButtons[button.tag];
    NSString *upImg = [post.upVotes containsObject:currentUser.userId] ? @"arrowupselected" : @"arrowup";
    [upButton setImage:[UIImage imageNamed:upImg] forState:UIControlStateNormal];
    
    UIButton *downButton = (UIButton *)self.arrowDownButtons[button.tag];
    NSString *downImg = [post.downVotes containsObject:currentUser.userId] ? @"arrowdownselected" : @"arrowdown";
    [downButton setImage:[UIImage imageNamed:downImg] forState:UIControlStateNormal];
    
    post.votes = post.upVotes.count - post.downVotes.count;
    UILabel *voteLabel = (UILabel *)self.votesLabels[button.tag];
    voteLabel.text = [NSString stringWithFormat:@"%i", post.votes];
    
    [post save:^(Post *post) { }];
}

-(void)downVoteButtonClick:(id)sender {
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] init];
        [MFHelpers open:loginView onView:self.superview];
        return;
    }
    
    UIButton *button = (UIButton *)sender;
    Post *post = self.posts[button.tag];
    
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
    
    UIButton *upButton = (UIButton *)self.arrowUpButtons[button.tag];
    NSString *upImg = [post.upVotes containsObject:currentUser.userId] ? @"arrowupselected" : @"arrowup";
    [upButton setImage:[UIImage imageNamed:upImg] forState:UIControlStateNormal];
    
    UIButton *downButton = (UIButton *)self.arrowDownButtons[button.tag];
    NSString *downImg = [post.downVotes containsObject:currentUser.userId] ? @"arrowdownselected" : @"arrowdown";
    [downButton setImage:[UIImage imageNamed:downImg] forState:UIControlStateNormal];
    
    post.votes = post.upVotes.count - post.downVotes.count;
    UILabel *voteLabel = (UILabel *)self.votesLabels[button.tag];
    voteLabel.text = [NSString stringWithFormat:@"%i", post.votes];
    
    [post save:^(Post *post) { }];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    CGPoint point = scrollView.contentOffset;
    if(point.y < -70)
    {
        [MFHelpers showProgressView:self.superview];
        MFView *view = (MFView *)self.superview;
        [view refresh];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([self.superview isMemberOfClass:[MFView class]])
    {
        MFView *view = (MFView *)self.superview;
        if (self.lastContentOffset > scrollView.contentOffset.y || scrollView.contentOffset.y < 30)
            [view scrollUp];
        else if (self.lastContentOffset < scrollView.contentOffset.y)
            [view scrollDown];
    }
    self.lastContentOffset = scrollView.contentOffset.y;
}

@end
