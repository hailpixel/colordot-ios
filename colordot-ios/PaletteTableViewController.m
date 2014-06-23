//
//  PaletteTableViewController.m
//  colordot-ios
//
//  Created by Colin on 6/20/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "PaletteTableViewController.h"


@interface PaletteTableViewController ()

@property CGFloat hue;
@property CGFloat saturation;
@property CGFloat brightness;

@property CGFloat xLagged;
@property CGFloat yLagged;
@property CGFloat xDelta;
@property CGFloat yDelta;

- (void)instantiateColorPickerViewForCell:(UITableViewCell *)cell;

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer;
- (void)panGestureUpdate:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)pinchGestureUpdate:(UIPinchGestureRecognizer *)gestureRecognizer;

- (void)updateColorWithPersistentValues;

@end

@implementation PaletteTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.xDelta = 0.0f;
    self.yDelta = 0.0f;
    self.xLagged = 0.0f;
    self.yLagged = 0.0f;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self instantiateColorPickerViewForCell:cell];
    
    return cell;
}

- (void)instantiateColorPickerViewForCell:(UITableViewCell *)cell
{
    CGRect cellBounds = cell.contentView.bounds;
    CGRect colorPickerViewFrame = CGRectMake(0.0f, 0.0f, cellBounds.size.width, cellBounds.size.width);
    UIView *colorPickerView = [[UIView alloc] initWithFrame:colorPickerViewFrame];
    self.colorPickerView = colorPickerView;
    
    colorPickerView.backgroundColor = [UIColor redColor];
    CGFloat hue = 0.0f, saturation = 0.0f, brightness = 0.0f;
    [colorPickerView.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:NULL];
    
    self.hue = hue;
    self.saturation = saturation;
    self.brightness = brightness;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    
    [colorPickerView addGestureRecognizer:panRecognizer];
    [colorPickerView addGestureRecognizer:pinchRecognizer];
    
    [cell.contentView addSubview:colorPickerView];
}


#pragma mark - Gesture handling
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer;
{
    // Call different methods depending on which gesture recognizer was fired
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        [self panGestureUpdate:(UIPanGestureRecognizer *)gestureRecognizer];
    }
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        [self pinchGestureUpdate:(UIPinchGestureRecognizer *)gestureRecognizer];
    }
}

- (void)panGestureUpdate:(UIPanGestureRecognizer *)gestureRecognizer
{
    // Update hue and brightness according to past delta values because gestureRecognizer fires on a gesture's ending
    self.hue += (self.xDelta/1000);
    self.brightness -= (self.yDelta/1000);
    
    // Loop hue value, rather than max/min values
    if (self.hue < 0.0f) self.hue += 1;
    else if (self.hue >= 1.0f) self.hue -= 1;
    
    if (self.brightness < 0.0f || self.brightness > 1.0f) self.brightness = MAX(MIN(self.brightness, 1.0f), 0.0f);
    
    [self updateColorWithPersistentValues];
    
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
    self.saturation += gestureRecognizer.velocity * 0.005f;
    if (self.saturation < 0.0f || self.saturation > 1.0f) self.saturation = MAX(MIN(self.saturation, 1.0f), 0.0f);
    
    [self updateColorWithPersistentValues];
}

#pragma mark Color updating
- (void)updateColorWithPersistentValues;
{
    // Set background color according to stored values
    UIColor *updatedColor = [UIColor colorWithHue:self.hue saturation:self.saturation brightness:self.brightness alpha:1.0f];
    self.colorPickerView.backgroundColor = updatedColor;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
