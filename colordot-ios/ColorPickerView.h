//
//  ColorPickerView.h
//  colordot-ios
//
//  Created by Colin on 6/24/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorPickerView : UIView

typedef enum {
    ColorPickerStateTouch,
    ColorPickerStateCameraInitializing,
    ColorPickerStateCameraOpening,
    ColorPickerStateCamera,
    ColorPickerStateCameraClosing
} ColorPickerState;

@property (nonatomic) ColorPickerState state;
@property (weak, nonatomic) UILabel *hexLabel;

@property (weak, nonatomic) UIButton *openCameraButton;
@property (weak, nonatomic) UIButton *closeCameraButton;

@end
