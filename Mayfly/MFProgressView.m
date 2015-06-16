//
//  MFProgressView.m
//  Mayfly
//
//  Created by Will Parks on 6/12/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFProgressView.h"

@implementation MFProgressView

-(id)init
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    self = [super initWithFrame:CGRectMake(0, 0, wd, ht)];
    if (self) {
        self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        [MBProgressHUD showHUDAddedTo:self animated:YES];
    }
    return self;
}

@end
