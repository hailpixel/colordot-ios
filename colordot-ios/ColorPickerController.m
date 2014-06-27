//
//  ColorPickerController.m
//  colordot-ios
//
//  Created by Devin Hunt on 6/24/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "ColorPickerController.h"
#import "UIColor+Increments.h"
#import "UIColor+HexString.h"

@interface ColorPickerController ()

@property CGFloat xLagged;
@property CGFloat yLagged;
@property CGFloat xDelta;
@property CGFloat yDelta;

- (void)panGestureUpdate:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)pinchGestureUpdate:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)respondToTap;

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
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureUpdate:)];
    [self.pickerView addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureUpdate:)];
    [self.pickerView addGestureRecognizer:pinchRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTap)];
    [self.pickerView addGestureRecognizer:tapRecognizer];
    
    self.view = self.pickerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    cpv.backgroundColor = [cpv.backgroundColor cho_colorWithChangeToHue:(self.xDelta/1000) saturation:0.0f brightness:-(self.yDelta/1000)];
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
    
    cpv.backgroundColor = [cpv.backgroundColor cho_colorWithChangeToSaturation:(gestureRecognizer.velocity * 0.005f)];
    cpv.hexLabel.text = [cpv.backgroundColor cho_hexString];
}

- (void)respondToTap
{
    [self.delegate colorPicked:self.pickerView.backgroundColor];
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
