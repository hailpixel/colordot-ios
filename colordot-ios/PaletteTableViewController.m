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
#import "ColorPickerController.h"

@interface PaletteTableViewController ()

@property NSMutableArray *colorsArray;
@property NSUInteger colorCount;
@property NSIndexPath *activeCellIndexPath;

- (void)instantiateColorPickerViewForCell:(UITableViewCell *)cell;

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
    
    self.colorsArray = [NSMutableArray arrayWithArray:@[WHITEHSB, [UIColor cyanColor], [UIColor orangeColor], [UIColor magentaColor], [UIColor yellowColor], [UIColor brownColor]]];
    self.colorCount = self.colorsArray.count;
    self.activeCellIndexPath = nil;
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
    cell.textLabel.text = [cell.backgroundColor cho_hexString];
    
    CGFloat brightness = 0.0f;
    [cell.backgroundColor getHue:NULL saturation:NULL brightness:&brightness alpha:NULL];
    
    
    if (brightness > 0.8f) cell.textLabel.textColor = [UIColor blackColor];
    else cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}


#pragma mark - Color Picker Management
#pragma mark Cell selection
- (void)instantiateColorPickerViewForCell:(UITableViewCell *)cell
{
    CGRect cellBounds = cell.contentView.bounds;
    CGRect colorPickerViewFrame = CGRectMake(0.0f, 0.0f, cellBounds.size.width, cellBounds.size.height);
    
    self.colorPickerController = [[ColorPickerController alloc] init];
    
    self.colorPickerController.view.frame = colorPickerViewFrame;
    
    
    self.colorPickerController.pickerView.backgroundColor = cell.backgroundColor;
    self.colorPickerController.pickerView.hexLabel.text = [cell.backgroundColor cho_hexString];
    
    [self addChildViewController:self.colorPickerController];
    [cell.contentView addSubview:self.colorPickerController.view];
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
        CGFloat inactiveCellHeight = 0.2f * (viewHeight - viewWidth);
        
        if ([indexPath isEqual:self.activeCellIndexPath]) {
            return viewHeight - ((self.colorCount - 1) * inactiveCellHeight);
        } else {
            return inactiveCellHeight;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"Active cell index path value: %@", self.activeCellIndexPath);
    
    if (!self.colorPickerController) {
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
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [self.activeCellIndexPath indexAtPosition:1];
    [self.colorsArray replaceObjectAtIndex:index withObject:self.colorPickerController.pickerView.backgroundColor];
    [self.tableView reloadData];
    
    [self.colorPickerController.view removeFromSuperview];
    [self.colorPickerController removeFromParentViewController];
    
    self.activeCellIndexPath = nil;
    self.colorPickerController = nil;
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
