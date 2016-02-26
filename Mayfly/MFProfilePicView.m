//
//  MFProfilePicView.m
//  Mayfly
//
//  Created by Will Parks on 6/9/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFProfilePicView.h"
#import "MFProfileView.h"
#import "MFView.h"

@interface MFProfilePicView ()

@property (nonatomic, assign) NSString *facebookId;

@end


@implementation MFProfilePicView

-(id)initWithFrame:(CGRect)frame facebookId:(NSString *)facebookId
{
    self = [super initWithFrame:frame];
    if (self) {
        self.facebookId = facebookId;
        [self addTarget:self action:@selector(facebookPicClicked:) forControlEvents:UIControlEventTouchUpInside];

        dispatch_queue_t queue = dispatch_queue_create("Facebook Profile Image Queue", NULL);
        
        dispatch_async(queue, ^{
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=140&height=140", facebookId]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setImage:img forState:UIControlStateNormal];
                self.layer.cornerRadius = frame.size.width / 2;
                self.clipsToBounds = YES;
            });
        });
        
    }
    return self;
}

-(id)initWithUrl:(CGRect)frame url:(NSString *)url {
    self = [super initWithFrame:frame];
    if (self) {
        dispatch_queue_t queue = dispatch_queue_create("Image Queue", NULL);
        
        dispatch_async(queue, ^{
            NSURL *nsurl = [NSURL URLWithString:url];
            NSData *data = [NSData dataWithContentsOfURL:nsurl];
            UIImage *img = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setImage:img forState:UIControlStateNormal];
                self.layer.cornerRadius = frame.size.width / 2;
                self.clipsToBounds = YES;
            });
        });
        
    }
    return self;
}


-(void)facebookPicClicked:(id)sender {
    if(![self.facebookId isKindOfClass:[NSNull class]] && self.facebookId.length > 0) {
        MFProfileView *profileView = [[MFProfileView alloc] init:self.facebookId];
        BOOL foundView = NO;
        UIView *view = self.superview;
        while(!foundView) {
            if([view isKindOfClass:[MFView class]]) {
                [MFHelpers openFromRight:profileView onView:view];
                foundView = YES;
            }
            else {
                view = view.superview;
            }
        }
    }
}


@end
