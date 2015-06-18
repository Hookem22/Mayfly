//
//  MFPillButton.h
//  Mayfly
//
//  Created by Will Parks on 6/10/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFPillButton : UIView

-(id)initWithFrame:(CGRect)frame yesText:(NSString *)yesText noText:(NSString *)noText;
-(void)switchButton;
-(BOOL)isYes;

@end
