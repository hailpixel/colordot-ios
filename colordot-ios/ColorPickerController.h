//
//  ColorPickerController.h
//  colordot-ios
//
//  Created by Devin Hunt on 6/24/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorPickerView.h"

@protocol ColorPickerDelegate <NSObject>

- (void)colorPicked:(UIColor *)color;

@end

@interface ColorPickerController : UIViewController

@property (nonatomic, strong) ColorPickerView *pickerView;
@property (nonatomic, weak) id <ColorPickerDelegate> delegate;

@end
