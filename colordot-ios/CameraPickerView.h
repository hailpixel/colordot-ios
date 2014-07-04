//
//  CameraPickerView.h
//  colordot-ios
//
//  Created by Devin Hunt on 6/25/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define kCameraPickerViewHoleRadius 120.0f

@interface CameraPickerView : UIView

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (weak, nonatomic) UIButton *pickerButton;

@end
