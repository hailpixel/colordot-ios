//
//  PaletteViewController.m
//  colordot-ios
//
//  Created by Colin on 6/27/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "PaletteViewController.h"

#import "UIColor+Increments.h"
#import "UIColor+HexString.h"
#import "UIColor+Random.h"

@interface PaletteViewController ()

@property NSMutableArray *colorsArray;
@property NSIndexPath *activeCellIndexPath;

@property (weak, nonatomic) UIView *dragUpView;
@property CGFloat yLagged;

@end


@implementation PaletteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.colorsArray = [NSMutableArray arrayWithArray:@[[UIColor cyanColor], [UIColor magentaColor], [UIColor yellowColor]]];
    self.activeCellIndexPath = nil;
    
    [self.panRecognizer addTarget:self action:@selector(respondToPan:)];
    
    [self setupDragUpView];
    [self updateButton];
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
    return self.colorsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [indexPath indexAtPosition:1];
    cell.backgroundColor = self.colorsArray[index];
    cell.textLabel.text = [cell.backgroundColor cho_hexString];
    cell.textLabel.textColor = [self whiteOrBlackWithColor:cell.backgroundColor];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.activeCellIndexPath != nil || self.colorsArray.count == 1) return NO;
    else return YES;
}


#pragma mark - Add/Remove methods
- (void)pullButtonAction:(id)sender
{
    if (self.colorsArray.count < 6) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self updateButton];
        }];
        
        [self.tableView beginUpdates];
        [self.colorsArray addObject:[UIColor randomColor]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.colorsArray.count - 1) inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
        
        [CATransaction commit];
    }
}

- (void)respondToPan:(UIGestureRecognizer *)gestureRecognizer;
{
    CGFloat y = [gestureRecognizer locationInView:self.view].y;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.dragUpView.backgroundColor = [UIColor randomColor];
        [UIView setAnimationsEnabled:NO];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat yDelta = y - self.yLagged;
        
        CGRect viewFrame = self.dragUpView.frame;
        CGRect buttonFrame = self.pullButton.frame;
        
        viewFrame.origin.y += yDelta;
        buttonFrame.origin.y += yDelta;
        viewFrame.size.height -= yDelta;
        
        [self.tableView beginUpdates];
        self.dragUpView.frame = viewFrame;
        [self.tableView endUpdates];
        self.pullButton.frame = buttonFrame;
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [UIView setAnimationsEnabled:YES];
    }
    
    self.yLagged = y;
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
    self.colorPickerController.delegate = self;
    
    [self addChildViewController:self.colorPickerController];
    [cell.contentView addSubview:self.colorPickerController.view];
}


#pragma mark Color Picker delegate methods
- (void)colorPicked:(UIColor *)color
{
    NSUInteger index = [self.activeCellIndexPath indexAtPosition:1];
    [self.colorsArray replaceObjectAtIndex:index withObject:color];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.activeCellIndexPath];
    [self configureCell:cell atIndexPath:self.activeCellIndexPath];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.pullButton.hidden = NO;
        [self updateButton];
    }];
    
    [self.tableView beginUpdates];
    [self.tableView deselectRowAtIndexPath:self.activeCellIndexPath animated:YES];
    [self dismissColorPicker];
    [self.tableView endUpdates];
    
    [CATransaction commit];
}


#pragma mark Table view delegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"Height calculating for index path: %@", indexPath);
    CGFloat viewHeight = self.tableView.bounds.size.height;
    CGFloat viewWidth = self.tableView.bounds.size.width;
    CGFloat dragHeight = self.dragUpView.bounds.size.height;
    
    if (self.activeCellIndexPath == nil) {
        return ROUNDUPHALF((viewHeight - dragHeight) / self.colorsArray.count);
    } else {
        CGFloat inactiveCellHeight = ROUNDUPHALF(0.2f * (viewHeight - viewWidth));
        
        if ([indexPath isEqual:self.activeCellIndexPath]) {
            return viewHeight - ((self.colorsArray.count - 1) * inactiveCellHeight);
        } else {
            return inactiveCellHeight;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"Active cell index path value: %@", self.activeCellIndexPath);
    self.pullButton.hidden = YES;
    
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
    [self dismissColorPicker];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUInteger index = [indexPath indexAtPosition:1];
        [self.colorsArray removeObjectAtIndex:index];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.pullButton.hidden = YES;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.pullButton.hidden = NO;
    [self updateButton];
}

#pragma mark - UIGestureRecognizer delegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGFloat y = [touch locationInView:self.view].y;
    if (y > (self.view.frame.size.height - 24) && self.activeCellIndexPath == nil) return YES;
    return NO;
}


#pragma mark - Private methods
// Split out because deselectRowAtIndexPath: doesn't call didDeselectRowAtIndexPath
- (void)dismissColorPicker
{
    [self.colorPickerController.view removeFromSuperview];
    [self.colorPickerController removeFromParentViewController];
    
    self.activeCellIndexPath = nil;
    self.colorPickerController = nil;
}

- (UIColor *)whiteOrBlackWithColor:(UIColor *)color
{
    CGFloat brightness = 0.0f;
    [color getHue:NULL saturation:NULL brightness:&brightness alpha:NULL];
    
    if (brightness > 0.8f) return [UIColor blackColor];
    return [UIColor whiteColor];
}

- (void)setupDragUpView
{
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    CGRect frame = CGRectMake(0, viewHeight, viewWidth, 0);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    [self.view addSubview:view];
    self.dragUpView = view;
}

- (void)updateButton
{
    UIColor *newColor = [self whiteOrBlackWithColor:[self.colorsArray objectAtIndex:(self.colorsArray.count - 1)]];
    self.pullButton.tintColor = [newColor colorWithAlphaComponent:0.63f];
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
