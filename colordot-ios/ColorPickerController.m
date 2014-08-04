//
//  ColorPickerController.m
//  colordot-ios
//
//  Created by Devin Hunt on 6/24/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "ColorPickerController.h"
#import "ColorPickerView.h"
#import "CameraPickerView.h"
#import "SlidingView.h"

#import "Color.h"
#import "Color+Increments.h"
#import "UIColor+HexString.h"

@interface ColorPickerController ()

@property CGFloat xLagged;
@property CGFloat yLagged;
@property CGFloat xDelta;
@property CGFloat yDelta;

- (void)panGestureUpdate:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)pinchGestureUpdate:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)respondToTap;

- (void)initializeCamera;

@end

@implementation ColorPickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    self.pickerView = [[ColorPickerView alloc] init];
    [self.pickerView.cameraButton addTarget:self action:@selector(onCameraButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureUpdate:)];
    panRecognizer.delegate = self;
    [self.pickerView addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureUpdate:)];
    [self.pickerView addGestureRecognizer:pinchRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTap)];
    [self.pickerView addGestureRecognizer:tapRecognizer];
    
    
    self.cameraView = [[CameraPickerView alloc] init];
    [self.cameraView.pickerButton addTarget:self action:@selector(onPickerButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *cameraTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToCameraTap:)];
    [self.cameraView addGestureRecognizer:cameraTapRecognizer];
    
    self.containerView = [[SlidingView alloc] init];
    self.view = self.containerView;
    self.containerView.centerView = self.pickerView;
    self.containerView.rightView = self.cameraView;

    // TODO initialize the camera only when needed
    [self initializeCamera];
    [cameraSession startRunning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pickerView.backgroundColor = self.activeColor.UIColor;
    self.pickerView.hexLabel.text = [self.pickerView.backgroundColor cho_hexString];
    
    self.xLagged = 0.0f;
    self.yLagged = 0.0f;
    self.xDelta = 0.0f;
    self.yDelta = 0.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.pickerView.hexLabel.center = self.view.center;
}

#pragma mark - Gesture Handling

- (void)panGestureUpdate:(UIPanGestureRecognizer *)gestureRecognizer
{
    ColorPickerView *cpv = self.pickerView;
    
    // Update hue and brightness according to past delta values because gestureRecognizer fires on a gesture's ending
    [self.activeColor cho_colorWithChangeToHue:(self.xDelta/1000) saturation:0.0f brightness:-(self.yDelta/1000)];
    cpv.backgroundColor = [self.activeColor UIColor];
    cpv.hexLabel.text = [cpv.backgroundColor cho_hexString];
    
    // Calculate the delta if the gesture is still occurring, otherwise reset delta values
    // Handling delta values in this way prevents a second gesture resulting in an abrupt change in the background color
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.xDelta = point.x - self.xLagged;
        self.yDelta = point.y - self.yLagged;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.xDelta = 0.0f;
        self.yDelta = 0.0f;
    }
    
    self.xLagged = point.x;
    self.yLagged = point.y;
}

- (void)pinchGestureUpdate:(UIPinchGestureRecognizer *)gestureRecognizer
{
    ColorPickerView *cpv = self.pickerView;
    
    [self.activeColor cho_colorWithChangeToSaturation:(gestureRecognizer.velocity * 0.005f)];
    cpv.backgroundColor = self.activeColor.UIColor;
    cpv.hexLabel.text = [cpv.backgroundColor cho_hexString];
}

- (void)respondToTap
{
    [self.delegate colorPicked:self.pickerView.backgroundColor];
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.pickerView];

    if(self.containerView.state == SlidingViewDefault && point.x > 200.0f) {
        return NO;
    }
    
    if(self.containerView.state == SlidingViewRight && point.x < 100.0f) {
        return NO;
    }
    
    return YES;
}

- (void)onCameraButtonTap {
    self.containerView.state = SlidingViewRight;
}

- (void)onPickerButtonTap {
    self.containerView.state = SlidingViewDefault;
}

#pragma mark - Camera methods
- (void)initializeCamera {
    cameraSession = [[AVCaptureSession alloc] init];
    cameraSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if(!input) {
        NSLog(@"Error grabbing input device");
    }
    
    [cameraSession addInput:input];
    
    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:cameraSession];
    self.cameraView.previewLayer = previewLayer;
    
    // Setup the sample buffer output
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    output.alwaysDiscardsLateVideoFrames = YES;
    output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [cameraSession addOutput:output];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    int bufferWidth = (int) CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int) CVPixelBufferGetHeight(pixelBuffer);
    
    int videoPointX = round((self.view.bounds.size.width / 2) * (CGFloat)bufferHeight / self.view.bounds.size.width);
    int videoPointY = round((self.view.bounds.size.height / 2) * (CGFloat)bufferWidth / self.view.bounds.size.height);
    
    unsigned char *rowBase = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    long bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    unsigned char *pixel = NULL;
    int avgRed = 0, avgGreen = 0, avgBlue = 0, x, y;
    
    for(y = videoPointY - 5; y < videoPointY + 5; y ++) {
        for(x = videoPointX - 5; x < videoPointX + 5; x ++) {
            pixel = rowBase + (x * bytesPerRow) + (y * 4);
            avgBlue += pixel[0];
            avgGreen += pixel[1];
            avgRed += pixel[2];
        }
    }
    
    avgBlue /= 100;
    avgGreen /= 100;
    avgRed /= 100;
    
    UIColor *sampledColor = [UIColor colorWithRed:avgRed / 255.0f green:avgGreen / 255.0f blue:avgBlue / 255.0f alpha:1.0f];
    self.cameraView.backgroundColor = sampledColor;
}

- (void)respondToCameraTap:(UITapGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateRecognized) {
        self.pickerView.backgroundColor = self.cameraView.backgroundColor;
        self.pickerView.hexLabel.text = [self.pickerView.backgroundColor cho_hexString];
        
        self.containerView.state = SlidingViewDefault;
    }
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
