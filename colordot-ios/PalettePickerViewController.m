//
//  PalettePickerViewController.m
//  colordot-ios
//
//  Created by Colin on 7/17/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "PalettePickerViewController.h"
#import "PaletteViewController.h"
#import "Palette.h"
#import "Color.h"

@interface PalettePickerViewController ()

@property (strong, nonatomic) Palette *selectedPalette;

@end

@implementation PalettePickerViewController

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
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"transparency"]];
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Palette *palette = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSArray *colorsArray = palette.colorsArray;
    NSUInteger numberOfColors = colorsArray.count;
    
    CGFloat colorWidth = 320.0f/(float)numberOfColors;
    CGFloat colorHeight = cell.contentView.frame.size.height;
    
    for (int i=0; i<numberOfColors; i++) {
        CGFloat colorX = i * colorWidth;
        CGRect frame = CGRectMake(colorX, 0.0f, colorWidth, colorHeight);
        UIView *colorView = [[UIView alloc] initWithFrame:frame];
        colorView.backgroundColor = ((Color *)colorsArray[i]).UIColor;
        
        [cell.contentView addSubview:colorView];
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPalette = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.selectedRow = indexPath;
    [self performSegueWithIdentifier:@"showPalette" sender:self];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Input handling
- (IBAction)addAction:(id)sender
{
    self.selectedPalette = [self instantiatePalette];
    [self performSegueWithIdentifier:@"showPalette" sender:self];
}


#pragma mark - Core Data methods

#pragma mark Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Palette" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *dateSavedSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    NSArray *sortDescriptors = @[dateSavedSortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"PalettePickerViewController"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark Object management
- (Palette *)instantiatePalette
{
    Palette *palette = [NSEntityDescription insertNewObjectForEntityForName:@"Palette" inManagedObjectContext:self.managedObjectContext];
    palette.created = [NSDate date];
    
    Color *color = [NSEntityDescription insertNewObjectForEntityForName:@"Color" inManagedObjectContext:self.managedObjectContext];
    [color randomValues];
    color.order = @0;
    
    [palette addColorsObject:color];
    [self saveContext];
    
    return palette;
}

- (void)saveContext
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unexpected error: %@, %@", error, [error userInfo]);
        abort();
    }
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PaletteViewController *pvc = (PaletteViewController *)[segue destinationViewController];
    pvc.managedObjectContext = self.managedObjectContext;
    pvc.palette = self.selectedPalette;
    self.selectedPalette = nil;
}

@end
