//
//  UIColor+Random.m
//  colordot-ios
//
//  Created by Colin on 6/27/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "UIColor+Random.h"

@implementation UIColor (Random)

+ (UIColor *)randomColor
{
    return [UIColor colorWithHue:RANDUNIFORM saturation:RANDUNIFORM brightness:RANDUNIFORM alpha:1.0f];
}

@end
