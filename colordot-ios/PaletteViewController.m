//
//  PaletteViewController.m
//  colordot-ios
//
//  Created by Colin on 6/27/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "PaletteViewController.h"
#import "PaletteVCGestureHandler.h"
#import "ColorPickerView.h"

#import "Palette.h"
#import "Color.h"

@interface PaletteViewController ()

@property (strong, nonatomic) PaletteVCGestureHandler *gestureHandler;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"transparency"]];
    
    self.colorsArray = self.palette.colorsArray;
    
    self.activeCellIndexPath = nil;
    self.gestureHandler = [[PaletteVCGestureHandler alloc] initWithPaletteVC:self];
    
    [self.panRecognizer addTarget:self.gestureHandler action:@selector(respondToPan:)];
    self.panRecognizer.delegate = self.gestureHandler;
    
    UIScreenEdgePanGestureRecognizer *screenEdgeRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self.gestureHandler action:@selector(respondToScreenEdge:)];
    screenEdgeRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:screenEdgeRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self.gestureHandler action:@selector(respondToLongPress:)];
    longPressRecognizer.delegate = self.gestureHandler;
    [self.view addGestureRecognizer:longPressRecognizer];
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    if (!(self.reorderingCellIndexPath == nil) && [indexPath isEqual:self.reorderingCellIndexPath]) {
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor clearColor];
    } else {
        NSUInteger index = [indexPath indexAtPosition:1];
        Color *cellColor = self.colorsArray[index];
        cell.backgroundColor = [cellColor UIColor];
        cell.textLabel.text = cellColor.hexString;
        cell.textLabel.textColor = [self whiteOrBlackWithColor:cell.backgroundColor];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.activeCellIndexPath != nil || self.colorsArray.count == 1) return NO;
    else return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark - Add/Remove methods
- (void)pullButtonAction:(id)sender
{
    if (self.colorsArray.count < 6) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self updateButton];
        }];
        
        [self.tableView beginUpdates];
        
        Color *color = [NSEntityDescription insertNewObjectForEntityForName:@"Color" inManagedObjectContext:self.managedObjectContext];
        [color randomValues];
        color.order = [NSNumber numberWithUnsignedInteger:self.palette.colors.count];
        [self.palette addColorsObject:color];
        [self saveContext];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.colorsArray.count - 1) inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        
        [self.tableView endUpdates];
        
        [CATransaction commit];
    }
}


#pragma mark - Color Picker Management
#pragma mark Cell selection
- (void)instantiateColorPickerViewForIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [indexPath indexAtPosition:1];
    self.colorPickerController = [[ColorPickerController alloc] initWithColor:self.colorsArray[index]];
    self.colorPickerController.delegate = self;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    CGRect cellBounds = cell.contentView.bounds;
    CGRect colorPickerViewFrame = CGRectMake(0.0f, 0.0f, cellBounds.size.width, cellBounds.size.height);
    self.colorPickerController.view.frame = colorPickerViewFrame;
    
    [self addChildViewController:self.colorPickerController];
    [cell.contentView addSubview:self.colorPickerController.view];
}


#pragma mark Color Picker delegate methods
- (void)colorPickerController:(ColorPickerController *)colorPickerController didPickColor:(UIColor *)color
{
    NSLog(@"paletteViewController colorPickerControllerDidPickColor began");
    [self saveContext];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.activeCellIndexPath];
    [self configureCell:cell atIndexPath:self.activeCellIndexPath];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        NSLog(@"paletteViewController colorPickerControllerDidPickColor completionBlock began");
        self.pullButton.hidden = NO;
        [self updateButton];
        NSLog(@"paletteViewController colorPickerControllerDidPickColor completionBlock ending");
    }];
    
    [self.tableView beginUpdates];
    
    [self.tableView deselectRowAtIndexPath:self.activeCellIndexPath animated:YES];
    [self tableView:self.tableView didDeselectRowAtIndexPath:self.activeCellIndexPath];
    
    [self.tableView endUpdates];
    
    [CATransaction commit];
    NSLog(@"paletteViewController colorPickerControllerDidPickColor ending");

}


#pragma mark Table view delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.pullButton.hidden = YES;
    
    if (!self.colorPickerController) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self instantiateColorPickerViewForIndexPath:indexPath];
        }];
        
        [self.tableView beginUpdates];
        self.activeCellIndexPath = indexPath;
        [self.tableView endUpdates];
        
        [CATransaction commit];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"paletteViewController didDeselectRowAtIndexPath began");
    [self.managedObjectContext refreshObject:self.colorPickerController.activeColor mergeChanges:NO];
    [self.colorPickerController.view removeFromSuperview];
    [self.colorPickerController removeFromParentViewController];
    
    self.activeCellIndexPath = nil;
    self.colorPickerController = nil;
    NSLog(@"paletteViewController didDeselectRowAtIndexPath ending");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUInteger index = [indexPath indexAtPosition:1];
        [self.palette removeColorsObject:self.colorsArray[index]];
        [self saveContext];
        [self updateOrder];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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


#pragma mark - Private methods
- (UIColor *)whiteOrBlackWithColor:(UIColor *)color
{
    CGFloat brightness = 0.0f;
    [color getHue:NULL saturation:NULL brightness:&brightness alpha:NULL];
    
    if (brightness > 0.8f) return [UIColor blackColor];
    return [UIColor whiteColor];
}

- (void)updateButton
{
    UIColor *color = [self whiteOrBlackWithColor:[[self.colorsArray objectAtIndex:(self.colorsArray.count - 1)] UIColor]];
    self.pullButton.tintColor = [color colorWithAlphaComponent:0.63f];
}

#pragma mark Data management
- (void)saveContext
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unexpected error: %@, %@", error, [error userInfo]);
        abort();
    }
    
    self.colorsArray = self.palette.colorsArray;
}

- (void)updateOrder
{
    for (Color *color in self.colorsArray) {
        color.order = [NSNumber numberWithUnsignedInteger:[self.colorsArray indexOfObject:color]];
    }
    
    [self saveContext];
}

#pragma mark Drag up view management
- (void)setupDragUpView
{
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    CGRect frame = CGRectMake(0, viewHeight, viewWidth, 0);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    [self.view addSubview:view];
    self.dragUpView = view;
    self.gestureHandler.dragUpView = view;
}

- (void)growDragUpViewByValue:(CGFloat)size
{
    CGRect frame = self.dragUpView.frame;
    
    frame.origin.y -= size;
    frame.size.height += size;

    [self.tableView beginUpdates];
    self.dragUpView.frame = frame;
    [self.tableView endUpdates];
}

@end
