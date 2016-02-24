//
//  MFProgressView.m
//  Mayfly
//
//  Created by Will Parks on 6/12/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFProgressView.h"

@interface MFProgressView()

@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;

@end

@implementation MFProgressView

-(id)init
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    self = [super initWithFrame:CGRectMake(0, 0, wd, ht)];
    if (self) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        //[MBProgressHUD showHUDAddedTo:self animated:YES];
        
        self.imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake((wd / 2) - 80, (ht / 2) - 80, 160, 160)];
        [self.imageView1 setImage:[UIImage imageNamed:@"launch1"]];
        [self addSubview:self.imageView1];
        
        self.imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake((wd / 2) - 80, (ht / 2) - 80, 160, 160)];
        [self.imageView2 setImage:[UIImage imageNamed:@"launch2"]];
        [self addSubview:self.imageView2];
        
        [self animate:nil];
        
    }
    return self;
}

-(void)animate:(id)sender {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:1.5
                          delay:0.5
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         self.imageView1.frame = CGRectMake(wd / 2 - 75, (ht / 2) - 80, 160, 160);
                         self.imageView2.frame = CGRectMake(wd / 2 - 85, (ht / 2) - 80, 160, 160);
                         self.self.imageView1.transform = CGAffineTransformRotate(self.imageView1.transform, M_PI * (-0.48));
                         self.self.imageView2.transform = CGAffineTransformRotate(self.imageView2.transform, M_PI * (.48));
                     }
                     completion:^(BOOL fin) {

                     }];
}

@end
