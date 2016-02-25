//
//  MFProfilePicView.h
//  Mayfly
//
//  Created by Will Parks on 6/9/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFProfilePicView : UIButton

-(id)initWithFrame:(CGRect)frame facebookId:(NSString *)facebookId;
-(id)initWithUrl:(CGRect)frame url:(NSString *)url;

@end
