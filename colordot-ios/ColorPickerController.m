//
//  ColorPickerController.m
//  colordot-ios
//
//  Created by Devin Hunt on 6/24/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "ColorPickerController.h"
#import "ColorPickerView.h"

#import "Color.h"
#import "Color+Increments.h"

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
        // init
    }
    return self;
}

- (id)initWithColor:(Color *)color
{
    self = [super init];
    if (self) {
        self.activeColor = color;
    }
    return self;
}

- (void)loadView {
    self.pickerView = [[ColorPickerView alloc] init];
    
    [self.pickerView.openCameraButton addTarget:self action:@selector(openCameraButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerView.closeCameraButton addTarget:self action:@selector(closeCameraButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureUpdate:)];
    panRecognizer.delegate = self;
    [self.pickerView addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureUpdate:)];
    [self.pickerView addGestureRecognizer:pinchRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTap)];
    [self.pickerView addGestureRecognizer:tapRecognizer];
    
    [self.pickerView setPickedColor:self.activeColor];
    
    self.view = self.pickerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pickerView.backgroundColor = self.activeColor.UIColor;
    self.pickerView.hexLabel.text = self.activeColor.hexString;
    
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
    [cpv setPickedColor: self.activeColor];
    
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
    [cpv setPickedColor: self.activeColor];
    cpv.hexLabel.text = self.activeColor.hexString;
}

- (void)respondToTap
{
    [self.delegate colorPickerController:self didPickColor:self.pickerView.backgroundColor];
    if(cameraSession) {
        [cameraSession stopRunning];
    }
}

#pragma mark - Camera methods

- (void)openCameraButtonTap {
    self.pickerView.state = ColorPickerStateCameraInitializing;
    [self initializeCamera];
}

- (void)closeCameraButtonTap {
    self.pickerView.state = ColorPickerStateCameraClosing;
    
    if(cameraSession && cameraSession.isRunning) {
        [cameraSession stopRunning];
    }
    cameraSession = nil;
}

- (void)initializeCamera {
    cameraSession = [[AVCaptureSession alloc] init];
    cameraSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    

    if([cameraSession canAddInput:input]) {
        [cameraSession addInput:input];
    }
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    output.alwaysDiscardsLateVideoFrames = YES;
    output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    if([cameraSession canAddOutput:output]) {
        [cameraSession addOutput:output];
    }
    
    // async startup of the camera session so it doesn't block UI input
    dispatch_queue_t layerQ = dispatch_queue_create("layerQ", NULL);
    dispatch_async(layerQ, ^{
        [cameraSession startRunning];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            AVCaptureVideoPreviewLayer *previewLayer;
            previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:cameraSession];
            
            self.pickerView.previewLayer = previewLayer;
            self.pickerView.state = ColorPickerStateCameraOpening;
        });
    });
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
    
    for (y = videoPointY - 5; y < videoPointY + 5; y ++) {
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
    
    CGFloat h, s, b;
    [sampledColor getHue:&h saturation:&s brightness:&b alpha:NULL];
    
    self.activeColor.hue = [NSNumber numberWithFloat:h];
    self.activeColor.saturation = [NSNumber numberWithFloat:s];
    self.activeColor.brightness = [NSNumber numberWithFloat:b];
    
    [self.pickerView setPickedColor:self.activeColor];
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
