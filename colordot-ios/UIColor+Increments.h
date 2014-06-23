//
//  UIColor+Increments.h
//  UIColorIncrements
//
//  Created by Colin on 3/13/14.
//  Copyright (c) 2014 Colin Jackson
//

#import <UIKit/UIKit.h>

@interface UIColor (Increments)

//  HSB-space UIColor incrementing
- (UIColor *)cho_colorWithChangeToHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
- (UIColor *)cho_colorWithChangeToHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness;
- (UIColor *)cho_colorWithChangeToHue:(CGFloat)hue;
- (UIColor *)cho_colorWithChangeToSaturation:(CGFloat)saturation;
- (UIColor *)cho_colorWithChangeToBrightness:(CGFloat)brightness;

//  RGB-space UIColor incrementing
- (UIColor *)cho_colorWithChangeToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (UIColor *)cho_colorWithChangeToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
- (UIColor *)cho_colorWithChangeToRed:(CGFloat)red;
- (UIColor *)cho_colorWithChangeToGreen:(CGFloat)green;
- (UIColor *)cho_colorWithChangeToBlue:(CGFloat)blue;

//  Alpha incrementing
//      Instantiating new colors
- (UIColor *)cho_colorWithChangeToAlpha:(CGFloat)alpha;

@end
