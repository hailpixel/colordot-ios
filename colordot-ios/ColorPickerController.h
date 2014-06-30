//
//  ColorPickerController.h
//  colordot-ios
//
//  Created by Devin Hunt on 6/24/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class ColorPickerView, CameraPickerView;

@interface ColorPickerController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession *cameraSession;
    AVCaptureVideoPreviewLayer *previewLayer;
}

@property (nonatomic, strong) ColorPickerView *pickerView;
@property (nonatomic, strong) CameraPickerView *cameraView;

@end
