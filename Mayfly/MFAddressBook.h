//
//  MFAddressBook.h
//  Mayfly
//
//  Created by Will Parks on 5/22/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MFCreateView.h"
#import "MFDetailView.h"

@interface MFAddressBook : UIView

- (id)initWithFrame:(CGRect)frame invited:(NSArray *)invited;

@end