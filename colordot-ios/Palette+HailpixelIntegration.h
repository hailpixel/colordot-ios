//
//  Palette+HailpixelIntegration.h
//  colordot-ios
//
//  Created by Colin on 10/18/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "Palette.h"

@interface Palette (HailpixelIntegration)

//- (id)initWithHailpixelURL:(NSURL *)hailpixelURL;
- (NSURL *)generateHailpixelURL;

@end
