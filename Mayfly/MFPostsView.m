//
//  MFPostsView.m
//  Pow Wow
//
//  Created by Will Parks on 2/29/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "MFPostsView.h"

@interface MFPostsView ()

@property (nonatomic, strong) NSMutableArray *posts;
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
         self.posts = [[NSMutableArray alloc] init];
         for(Post *post in posts) {
             if(!post.isPrivate) {
                 [self.posts addObject:post];
             }
         }
         
         [[Session sessionVariables] setObject:self.posts forKey:@"currentPosts"];
         [self populateAll];
         
         [MFHelpers hideProgressView:self.superview];
     }];
}

-(void)populateAll {
    self.posts = (NSMutableArray *)[Session sessionVariables][@"currentPosts"];
    
    [self populate];
    [self loadMessageImages];
}

-(void)populateMyInterests {
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    NSString *groupIds = @"";
    for(Group *group in currentUser.groups) {
        groupIds = [NSString stringWithFormat:@"%@|%@", groupIds, group.groupId];
    }
    
    NSMutableArray *myPosts = [[NSMutableArray alloc] init];
    for(Post *post in self.posts) {
        if([groupIds rangeOfString:post.groupId].location != NSNotFound) {
            [myPosts addObject:post];
        }
    }
    
    self.posts = myPosts;
    [self populate];
    [self loadMessageImages];
}

-(void)addPost:(Post *)post {
    NSMutableArray *posts = [[NSMutableArray alloc] init];
    [posts addObject:post];
    for(Post *item in self.posts)
        [posts addObject:item];
    
    self.posts = posts;
    [self populate];
    [self loadMessageImages];
    
    NSMutableArray *currentPosts = (NSMutableArray *)[Session sessionVariables][@"currentPosts"];
    NSMutableArray *allPosts = [[NSMutableArray alloc] init];
    [allPosts addObject:post];
    for(Post *item in currentPosts)
        [allPosts addObject:item];
    
    [[Session sessionVariables] setObject:allPosts forKey:@"currentPosts"];
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
                    float imgWd = wd;
                    float imgHt = (imgWd / img.size.width) * img.size.height;
                    imageView.frame = CGRectMake(0, 0, imgWd, imgHt);
                    [self.postImageViews setObject:imageView forKey:post.postId];
                    [self refreshImages];
                });
            });
        }
    }
}

-(void)populate {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
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
        UIButton *postView = [[UIButton alloc] initWithFrame:CGRectMake(0, viewY, wd, 185)];
        [postView addTarget:self action:@selector(postClicked:) forControlEvents:UIControlEventTouchUpInside];
        postView.backgroundColor = [UIColor whiteColor];
        postView.tag = tag;
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
        
        UILabel *groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, wd, 20)];
        groupLabel.text = post.groupName;
        groupLabel.textAlignment = NSTextAlignmentCenter;
        groupLabel.font = [UIFont boldSystemFontOfSize:16];
        [postView addSubview:groupLabel];
        
        UIView *groupBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 49, wd, 1)];
        groupBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [postView addSubview:groupBorder];
        
        MFProfilePicView *messagePic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(30, 60, 50, 50) facebookId:post.facebookId];
        [postView addSubview:messagePic];
        
        UILabel *nameMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 65, wd - 90, 20)];
        nameMessageLabel.text = post.name;
        [postView addSubview:nameMessageLabel];
        
        UILabel *dateMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 90, wd - 90, 20)];
        dateMessageLabel.text = [MFHelpers dateDiffBySeconds:post.secondsSince];
        dateMessageLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
        [postView addSubview:dateMessageLabel];
        
        UIButton *upVoteButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 70, 50, 40, 40)];
        NSString *upImg = [post.upVotes containsObject:currentUser.userId] ? @"arrowupselected" : @"arrowup";
        [upVoteButton setImage:[UIImage imageNamed:upImg] forState:UIControlStateNormal];
        [upVoteButton addTarget:self action:@selector(upVoteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        upVoteButton.tag = tag;
        [self.arrowUpButtons addObject:upVoteButton];
        [postView addSubview:upVoteButton];
        
        UILabel *votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(wd - 89, 70, 80, 40)];
        votesLabel.text = [NSString stringWithFormat:@"%i", post.votes];
        votesLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
        votesLabel.font = [UIFont boldSystemFontOfSize:24.f];
        votesLabel.textAlignment = NSTextAlignmentCenter;
        [self.votesLabels addObject:votesLabel];
        [postView addSubview:votesLabel];
        
        UIButton *downVoteButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 70, 92, 40, 40)];
        NSString *downImg = [post.downVotes containsObject:currentUser.userId] ? @"arrowdownselected" : @"arrowdown";
        [downVoteButton setImage:[UIImage imageNamed:downImg] forState:UIControlStateNormal];
        [downVoteButton addTarget:self action:@selector(downVoteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        downVoteButton.tag = tag;
        [self.arrowDownButtons addObject:downVoteButton];
        [postView addSubview:downVoteButton];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 130, wd - 60, 20)];
        messageLabel.text = post.message;
        messageLabel.numberOfLines = 0;
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.tag = 1;
        [messageLabel sizeToFit];
        [postView addSubview:messageLabel];
        
        int imgHt = 0;
        if(post.hasImage) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(60, messageLabel.frame.size.height + 150, 80, 80);
            //[imageView setImage:[UIImage imageNamed:@"portrait"]];
            [postView addSubview:imageView];
            imageView.tag = 2;
            imgHt = imageView.frame.size.height + 10;
        }
        
        if(messageLabel.frame.size.height + imgHt + 150 > postView.frame.size.height) {
            postView.frame = CGRectMake(0, viewY, wd, messageLabel.frame.size.height + imgHt + 165);
        }
        
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, postView.frame.size.height - 24, wd, 20)];
        NSString *commentText = post.comments.count == 1 ? @"1 Comment" : [NSString stringWithFormat:@"%i Comments", (int)post.comments.count];
        [commentLabel setText:commentText];
        commentLabel.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
        [commentLabel setFont:[UIFont boldSystemFontOfSize:14]];
        commentLabel.textAlignment = NSTextAlignmentCenter;
        commentLabel.tag = 20;
        [postView addSubview:commentLabel];
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:commentLabel.font, NSFontAttributeName, nil];
        CGFloat commentWd = [[[NSAttributedString alloc] initWithString:commentLabel.text attributes:attributes] size].width;
        
        UIImageView *commentImageView = [[UIImageView alloc] initWithFrame:CGRectMake((wd - (int)commentWd) / 2 - 18, postView.frame.size.height - 21, 16, 16)];
        [commentImageView setImage:[UIImage imageNamed:@"comment"]];
        commentImageView.tag = 20;
        [postView addSubview:commentImageView];
        
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
    
    if(self.posts.count == 0) {
        UIButton *postView = [[UIButton alloc] initWithFrame:CGRectMake(0, viewY, wd, 185)];
        [postView addTarget:self action:@selector(postClicked:) forControlEvents:UIControlEventTouchUpInside];
        postView.backgroundColor = [UIColor whiteColor];
        postView.tag = tag;
        [self addSubview:postView];
        
        UIView *middle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, 11)];
        middle.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        [postView addSubview:middle];
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 11, wd, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [postView addSubview:bottomBorder];
        
        UILabel *groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, wd, 20)];
        groupLabel.text = @"St. Edward's";
        groupLabel.textAlignment = NSTextAlignmentCenter;
        groupLabel.font = [UIFont boldSystemFontOfSize:16];
        [postView addSubview:groupLabel];
        
        UIView *groupBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 49, wd, 1)];
        groupBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [postView addSubview:groupBorder];
        
        MFProfilePicView *messagePic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(30, 60, 50, 50) facebookId:currentUser.facebookId];
        [postView addSubview:messagePic];
        
        UILabel *nameMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 76, wd - 90, 20)];
        nameMessageLabel.text = currentUser.name;
        [postView addSubview:nameMessageLabel];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 130, wd - 60, 20)];
        messageLabel.text = @"You do not have anything going on in your interests currently. Join more interests to see what's going on around St. Edward's";
        messageLabel.numberOfLines = 0;
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.tag = 1;
        [messageLabel sizeToFit];
        [postView addSubview:messageLabel];
        
        if(messageLabel.frame.size.height + 150 > postView.frame.size.height) {
            postView.frame = CGRectMake(0, viewY, wd, messageLabel.frame.size.height + 165);
        }

        UIView *topBorder2 = [[UIView alloc] initWithFrame:CGRectMake(0, postView.frame.size.height, wd, 1)];
        topBorder2.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [postView addSubview:topBorder2];
        
        UIView *middle2 = [[UIView alloc] initWithFrame:CGRectMake(0, postView.frame.size.height + 1, wd, 300)];
        middle2.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        [postView addSubview:middle2];
        postView.frame = CGRectMake(postView.frame.origin.x, postView.frame.origin.y, postView.frame.size.width, postView.frame.size.height + 80);
    }
    
    self.contentSize = CGSizeMake(wd, viewY);
    
    if(self.contentSize.height < ht)
        self.contentSize = CGSizeMake(wd, ht - 40);
}

-(void)postClicked:(id)sender {
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] init];
        [MFHelpers open:loginView onView:self.superview];
        return;
    }
    
    if(self.posts.count == 0) {
        return;
    }
    
    UIButton *button = (UIButton *)sender;
    Post *post = self.posts[button.tag];
    [self openPost:post];
}

-(void)goToPost:(NSString *)postId {
    [Post get:postId completion:^(Post *post) {
        [self openPost:post];
    }];
}

-(void)openPost:(Post *)post {
    MFPostDetailView *detailView = [[MFPostDetailView alloc] init:post];
    [MFHelpers openFromRight:detailView onView:self.superview];
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
                        imageView.frame = CGRectMake(0, messageLabelHt + 150, imageViewWithPic.frame.size.width, imageViewWithPic.frame.size.height);
                        
                        imgHt = imageView.frame.size.height + 20;
                    }
                }
            }
            
            if(messageLabelHt + imgHt + 120 > postView.frame.size.height) {
                postView.frame = CGRectMake(0, viewY, postView.frame.size.width, messageLabelHt + imgHt + 165);
            }
            
            for(UIView *subview in postView.subviews) {
                if (subview.tag == 20) {
                    if([subview isMemberOfClass:[UILabel class]]) {
                        subview.frame = CGRectMake(subview.frame.origin.x, postView.frame.size.height - 24, subview.frame.size.width, subview.frame.size.height);
                    }
                    else if([subview isMemberOfClass:[UIImageView class]]) {
                        subview.frame = CGRectMake(subview.frame.origin.x, postView.frame.size.height - 21, subview.frame.size.width, subview.frame.size.height);
                    }
                }
            }
        }
        viewY += postView.frame.size.height;
        i++;
    }
    
    self.contentSize = CGSizeMake(self.frame.size.width, viewY);
    
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    if(self.contentSize.height < ht)
        self.contentSize = CGSizeMake(wd, ht - 40);
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
    
    post.votes = (int)post.upVotes.count - (int)post.downVotes.count;
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
    
    post.votes = (int)post.upVotes.count - (int)post.downVotes.count;
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
