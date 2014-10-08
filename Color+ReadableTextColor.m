//
//  Color+ReadableTextColor.m
//  colordot-ios
//
//  Created by Colin on 10/8/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "Color+ReadableTextColor.h"

@implementation Color (ReadableTextColor)

- (UIColor *)readableTextColor
{
    CGFloat red, green, blue;
    [self.UIColor getRed:&red green:&green blue:&blue alpha:NULL];
    
    CGFloat luminosity = (0.2126 * pow(red, 2.2)) + (0.7152 * pow(green, 2.2)) + (0.0722 * pow(blue, 2.2));
    
    UIColor *readableColor = (luminosity > 0.5 ? BLACKHSB : WHITEHSB);
    
    return readableColor;
}

@end
