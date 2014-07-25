//
//  Color+Increments.h
//  colordot-ios
//
//  Created by Colin on 7/25/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "Color.h"

@interface Color (Increments)

//  HSB-space UIColor incrementing
- (void)cho_colorWithChangeToHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
- (void)cho_colorWithChangeToHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness;
- (void)cho_colorWithChangeToHue:(CGFloat)hue;
- (void)cho_colorWithChangeToSaturation:(CGFloat)saturation;
- (void)cho_colorWithChangeToBrightness:(CGFloat)brightness;

@end
