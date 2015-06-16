//
//  MFMessageView.h
//  Mayfly
//
//  Created by Will Parks on 6/15/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFHelpers.h"

@interface MFMessageView : UIView <UITextFieldDelegate>

-(id)init:(Event *)event;

@end
