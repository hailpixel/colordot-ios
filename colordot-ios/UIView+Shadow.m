//
//  UIView+Shadow.m
//  colordot-ios
//
//  Created by Colin on 8/21/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "UIView+Shadow.h"

@implementation UIView (Shadow)

- (void)addShadow
{
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = 8;
    self.layer.shadowOpacity = 0.5;
}

@end
