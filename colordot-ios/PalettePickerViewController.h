//
//  PalettePickerViewController.h
//  colordot-ios
//
//  Created by Colin on 7/17/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Palette;

@interface PalettePickerViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Palette *selectedPalette;

- (IBAction)addAction:(id)sender;

@end
