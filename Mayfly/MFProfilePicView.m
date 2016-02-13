//
//  MFProfilePicView.m
//  Mayfly
//
//  Created by Will Parks on 6/9/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFProfilePicView.h"

@implementation MFProfilePicView

-(id)initWithFrame:(CGRect)frame facebookId:(NSString *)facebookId
{
    self = [super initWithFrame:frame];
    if (self) {
        dispatch_queue_t queue = dispatch_queue_create("Facebook Profile Image Queue", NULL);
        
        dispatch_async(queue, ^{
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=100&height=100", facebookId]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setImage:img];
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
                [self setImage:img];
                self.layer.cornerRadius = frame.size.width / 2;
                self.clipsToBounds = YES;
            });
        });
        
    }
    return self;
}


@end
