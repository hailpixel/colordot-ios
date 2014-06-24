//
//  PaletteTableViewController.h
//  colordot-ios
//
//  Created by Colin on 6/20/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColorPickerView;

@interface PaletteTableViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) ColorPickerView *colorPickerView;

@end
