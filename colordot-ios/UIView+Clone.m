//
//  UIView+Clone.m
//  colordot-ios
//
//  Created by Colin on 8/21/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "UIView+Clone.h"

@implementation UIView (Clone)

- (UIView *)clone
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

@end
