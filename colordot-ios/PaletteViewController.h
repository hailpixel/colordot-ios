//
//  PaletteViewController.h
//  colordot-ios
//
//  Created by Colin on 6/27/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorPickerController.h"

@class Palette;

@interface PaletteViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, ColorPickerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Palette *palette;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *pullButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panRecognizer;

@property (strong, nonatomic) ColorPickerController *colorPickerController;
@property (strong, nonatomic) NSArray *colorsArray;
@property (strong, nonatomic) NSIndexPath *activeCellIndexPath;
@property (strong, nonatomic) NSIndexPath *reorderingCellIndexPath;

- (IBAction)pullButtonAction:(id)sender;
- (IBAction)shareButtonAction:(id)sender;
- (void)growDragUpViewByValue:(CGFloat)size;
- (void)saveContext;

- (void)setReorderingCellIndexPathForTouchPoint:(CGPoint)touchPoint;

@end