//
//  ColorPickerController.h
//  colordot-ios
//
//  Created by Devin Hunt on 6/24/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class SlidingView, ColorPickerView, CameraPickerView;

@protocol ColorPickerDelegate <NSObject>

- (void)colorPicked:(UIColor *)color;

@end

@interface ColorPickerController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate> {
    AVCaptureSession *cameraSession;
    AVCaptureVideoPreviewLayer *previewLayer;
}

@property (nonatomic, strong) SlidingView *containerView;
@property (nonatomic, strong) ColorPickerView *pickerView;
@property (nonatomic, strong) CameraPickerView *cameraView;
@property (nonatomic, weak) id <ColorPickerDelegate> delegate;

@end
