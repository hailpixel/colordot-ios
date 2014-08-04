//
//  Color.h
//  colordot-ios
//
//  Created by Colin on 7/18/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Palette;

@interface Color : NSManagedObject

@property (nonatomic, retain) NSNumber *brightness;
@property (nonatomic, retain) NSNumber *hue;
@property (nonatomic, retain) NSNumber *saturation;
@property (nonatomic, retain) NSNumber *order;
@property (nonatomic, retain) Palette *palette;

- (UIColor *)UIColor;
- (NSString *)hexString;
- (void)randomValues;

@end
