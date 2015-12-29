//
//  MFCreateGroupView.h
//  Pow Wow
//
//  Created by Will Parks on 12/29/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFHelpers.h"
#import "MFPillButton.h"
#import "MFLoginView.h"
#import "Group.h"

@interface MFCreateGroupView : UIView <UITextFieldDelegate, UITextViewDelegate>

-(id)init:(Group *)group;

@end
