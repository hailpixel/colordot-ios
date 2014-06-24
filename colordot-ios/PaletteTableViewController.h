//
//  PaletteTableViewController.h
//  colordot-ios
//
//  Created by Colin on 6/20/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColorPickerController;

@interface PaletteTableViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) ColorPickerController *colorPickerController;

@end
