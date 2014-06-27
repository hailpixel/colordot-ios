//
//  PaletteViewController.h
//  colordot-ios
//
//  Created by Colin on 6/27/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorPickerController.h"

@interface PaletteViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ColorPickerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *pullButton;

@property (strong, nonatomic) ColorPickerController *colorPickerController;

@end