//
//  MFClockView.h
//  Mayfly
//
//  Created by Will Parks on 6/10/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFClockView : UIView

-(id)initWithFrame:(CGRect)frame placeHolder:(NSString *)placeHolder;
-(NSDate *)getTime;

@end