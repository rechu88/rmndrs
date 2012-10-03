//
//  SettingsViewController.m
//  Rmndrs
//
//  Created by Reshma Unnikrishnan on 01/09/12.
//  Copyright (c) 2012 Personal. All rights reserved.
//

#import "SettingsViewController.h"
#import "GlobalSettings.h"

#import "DDBadgeViewCell.h"

#define BOOL_TRUE @"TRUE"
#define BOOL_FALSE @"FALSE"

@implementation SettingsViewController

@synthesize settingDetail;

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Settings", @"Settings");
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self customizeTable];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (void)configureCell:(DDBadgeViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Settings *thisManagedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *name = [thisManagedObject valueForKey:@"name"];
    NSString *settingsType = [thisManagedObject valueForKey:@"type"];
    NSString *badgeValue = [thisManagedObject valueForKey:@"value"];
    NSString *imgValue = [thisManagedObject valueForKey:@"img"];
    
    if([settingsType isEqualToString:@"interpret"]) {
        badgeValue = [GlobalSettings interpretUserSettings:badgeValue key:name];
    }
    
    if([settingsType isEqualToString:@"boolean"]) {
        cell.textLabel.text = name;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        [switchView setOn:(([badgeValue isEqualToString:BOOL_TRUE])? YES : NO) animated:NO];
        [switchView addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
        //        }
    } else {
        cell.summary = name;
        cell.badgeText = badgeValue;
        cell.badgeHighlightedColor = [GlobalSettings badgeSelectedColor];
    }
    
    if (imgValue != nil) {
        cell.imageView.image = [UIImage imageNamed:imgValue];
    }
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    DDBadgeViewCell *cell;
    
    Settings *thisManagedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *settingsType = [thisManagedObject valueForKey:@"type"];
    NSString *badgeValue = [thisManagedObject valueForKey:@"value"];
    NSString *imgValue = [thisManagedObject valueForKey:@"img"];

    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if([settingsType isEqualToString:@"boolean"]) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        } else {
            cell = [[DDBadgeViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withImage:TRUE];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
   
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(DDBadgeViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell.textLabel setFont:[GlobalSettings baseFont:19.0]];
    [cell setBackgroundColor:[GlobalSettings baseCellBackgroundColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.settingDetail =[[settingDetailViewController alloc]initWithNibName:@"settingDetailViewController" bundle:nil];    
    [self.navigationController pushViewController:self.settingDetail animated:YES];
}

-(void) customizeTable 
{
    self.tableView.backgroundColor = [GlobalSettings backImage];
}

-(void) switchChanged
{
    
}

// Core Data Stuff

#pragma mark - Fetched results controller

- (void)prepopulateSettings
{
    NSArray *objects = [__fetchedResultsController fetchedObjects];
    
    bool alarmSet = FALSE;
    bool reminderBeforeSet = FALSE;
    bool snoozeSet = FALSE;
    
    for(int i=0; i < [objects count]; ++i) {
        NSManagedObject *mObj = [objects objectAtIndex:i];
        NSString *name = [mObj valueForKey:@"name"];
        NSLog(@" SETTINGS NAME :: %@", name);
        if([name isEqualToString:DB_ALARM_KEY]) {
            alarmSet = TRUE;
        }
        if([name isEqualToString:DB_REMINDER_KEY]) {
            reminderBeforeSet = TRUE;
        }
        if([name isEqualToString:DB_SNOOZE_KEY]) {
            snoozeSet = TRUE;
        }
    }   
    
    if(alarmSet == FALSE) {
        [self insertNewObject:DB_ALARM_KEY type:@"string" value:@"default" img:@"music.png"];
    }
    if(reminderBeforeSet == FALSE) {
        [self insertNewObject:DB_REMINDER_KEY type:@"interpret" value:@"2m" img:@"alarm.png"];
    }
    if(snoozeSet == FALSE) {
        [self insertNewObject:DB_SNOOZE_KEY type:@"boolean" value:@"FALSE" img:@"snooze.png"];
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Settings"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    [self prepopulateSettings];
    [NSFetchedResultsController deleteCacheWithName:@"Settings"];
    
    NSLog(@"FECTHED DATA : %@", sortDescriptors);
    
    return __fetchedResultsController;
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
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self configureCell:[tableView cellForRowAtIndexPath:newIndexPath] atIndexPath:newIndexPath];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:newIndexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:newIndexPath];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

// End Core Data Stuff

// Core data Insert

- (NSManagedObject *)insertNewObject:(NSString *)name type:(NSString *)type value:(NSString *)value img:(NSString *)img
{
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newManagedObject setValue:name forKey:@"name"];
    [newManagedObject setValue:value forKey:@"value"];
    [newManagedObject setValue:type forKey:@"type"];
    [newManagedObject setValue:img forKey:@"img"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return newManagedObject;
}

// Core data Insert End

@end
