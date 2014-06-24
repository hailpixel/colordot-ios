//
//  PaletteTableViewController.m
//  colordot-ios
//
//  Created by Colin on 6/20/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "PaletteTableViewController.h"
#import "UIColor+Increments.h"
#import "UIColor+HexString.h"
#import "ColorPickerView.h"

@interface PaletteTableViewController ()

@property CGFloat xLagged;
@property CGFloat yLagged;
@property CGFloat xDelta;
@property CGFloat yDelta;

@property NSMutableArray *colorsArray;
@property NSUInteger colorCount;
@property NSIndexPath *activeCellIndexPath;

- (void)instantiateColorPickerViewForCell:(UITableViewCell *)cell;

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer;
- (void)panGestureUpdate:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)pinchGestureUpdate:(UIPinchGestureRecognizer *)gestureRecognizer;

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
    
    self.colorsArray = [NSMutableArray arrayWithArray:@[[UIColor whiteColor], [UIColor cyanColor], [UIColor orangeColor], [UIColor magentaColor], [UIColor yellowColor], [UIColor brownColor]]];
    self.colorCount = self.colorsArray.count;
    self.activeCellIndexPath = nil;
    
    self.xDelta = 0.0f;
    self.yDelta = 0.0f;
    self.xLagged = 0.0f;
    self.yLagged = 0.0f;
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
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSUInteger index = [indexPath indexAtPosition:1];
    cell.backgroundColor = self.colorsArray[index];
    
    return cell;
}


#pragma mark - Color Picker Management
#pragma mark Cell selection
- (void)instantiateColorPickerViewForCell:(UITableViewCell *)cell
{
    CGRect cellBounds = cell.contentView.bounds;
    CGRect colorPickerViewFrame = CGRectMake(0.0f, 0.0f, cellBounds.size.width, cellBounds.size.width);
    ColorPickerView *colorPickerView = [[ColorPickerView alloc] initWithFrame:colorPickerViewFrame];
    self.colorPickerView = colorPickerView;
    
    colorPickerView.backgroundColor = cell.backgroundColor;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    
    [colorPickerView addGestureRecognizer:panRecognizer];
    [colorPickerView addGestureRecognizer:pinchRecognizer];
    
    [cell.contentView addSubview:colorPickerView];
}

#pragma mark Gesture handling
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
    self.colorPickerView.backgroundColor = [self.colorPickerView.backgroundColor cho_colorWithChangeToHue:(self.xDelta/1000) saturation:0.0f brightness:-(self.yDelta/1000)];
    
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
    self.colorPickerView.backgroundColor = [self.colorPickerView.backgroundColor cho_colorWithChangeToSaturation:(gestureRecognizer.velocity * 0.005f)];
}


#pragma mark - Table view delegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"Height calculating for index path: %@", indexPath);
    CGFloat viewHeight = self.tableView.bounds.size.height;
    CGFloat viewWidth = self.tableView.bounds.size.width;
    
    if (self.activeCellIndexPath == nil) {
        return (viewHeight / self.colorCount);
    } else {
        if ([indexPath isEqual:self.activeCellIndexPath]) {
            return viewWidth;
        } else {
            return (viewHeight - viewWidth) / (self.colorCount - 1);
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self instantiateColorPickerViewForCell:cell];
    }];
    
    [self.tableView beginUpdates];
    self.activeCellIndexPath = indexPath;
    [self.tableView endUpdates];
    
    [CATransaction commit];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [self.activeCellIndexPath indexAtPosition:1];
    [self.colorsArray replaceObjectAtIndex:index withObject:self.colorPickerView.backgroundColor];
    [self.tableView reloadData];
    
    [self.colorPickerView removeFromSuperview];
    self.activeCellIndexPath = nil;
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
