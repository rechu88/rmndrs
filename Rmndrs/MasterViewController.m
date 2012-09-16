//
//  MasterViewController.m
//  Rmndrs
//
//  Created by Reshma Unnikrishnan on 01/09/12.
//  Copyright (c) 2012 Personal. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "SettingsViewController.h"

#import "GlobalSettings.h"

#import "DDBadgeViewCell.h"

#define NAVCOLOR [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]

#define NOWBADGESECTION 0
#define SOONBADGESECTION 1
#define AFTERBADGESECTION 2

@interface MasterViewController ()
- (void)configureCell:(DDBadgeViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;

@synthesize remindersAll;
@synthesize remindersNow;
@synthesize remindersSoon;
@synthesize remindersAfter;

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

#pragma mark -
#pragma mark Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Rmndrs", @"Rmndrs");
        self.tableView.rowHeight = 60.0;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self customizeNavBar];
    [self createSettingsBarButton];
    [self createAddContactsBarButton];
    
    [self customizeTable];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    DDBadgeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DDBadgeViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    cell.badgeHighlightedColor = [GlobalSettings badgeSelectedColor];
    cell.imageView.image = [UIImage imageNamed:@"contact.png"];
    
    return cell;
}

- (void)configureCell:(DDBadgeViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.summary = [managedObject valueForKey:@"name"];
    cell.detail = [managedObject valueForKey:@"phone"];
    
    if(indexPath.section == NOWBADGESECTION) {
        cell.badgeText = @"Now";
        cell.badgeColor = [GlobalSettings badgeNowColor];
    } else if(indexPath.section == SOONBADGESECTION) {
        cell.badgeText = @"Soon";
        cell.badgeColor = [GlobalSettings badgeSoonColor];
    } else if(indexPath.section == AFTERBADGESECTION) {
        cell.badgeText = @"After";
        cell.badgeColor = [GlobalSettings badgeAfterColor];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(DDBadgeViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell.textLabel setFont:[GlobalSettings baseFont:19.0]];
    [cell setBackgroundColor:[GlobalSettings baseCellBackgroundColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (!self.detailViewController) {
        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    }
    NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    self.detailViewController.managedObject = selectedObject;   
    
    self.detailViewController.name = (NSString *)[selectedObject valueForKey:@"name"];
    self.detailViewController.phone = (NSString *)[selectedObject valueForKey:@"phone"];
    
    self.detailViewController.frequency = (NSString *)[selectedObject valueForKey:@"freq"];
    self.detailViewController.time = [selectedObject valueForKey:@"time"];
    
    self.detailViewController.viewTitle = @"Edit Rmndr";
    
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

-(void) createSettingsBarButton
{
    UIImage* settingsImg = [UIImage imageNamed:@"settings.png"];
    CGRect frameimg = CGRectMake(0, 0, 40, 40);
    UIButton *settingsButton = [[UIButton alloc] initWithFrame:frameimg];
    [settingsButton setImage:settingsImg forState:UIControlStateNormal];

    [settingsButton addTarget:self action:@selector(clickedSettings)
         forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *settingsBarButton =[[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.leftBarButtonItem = settingsBarButton;
}

-(void) clickedSettings
{
    SettingsViewController *settings = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [self.navigationController pushViewController:settings animated:YES];}

-(void) createAddContactsBarButton
{
    UIImage* contactsImg = [UIImage imageNamed:@"contact.png"];
    CGRect frameimg = CGRectMake(0, 0, 40, 40);
    UIButton *contactsButton = [[UIButton alloc] initWithFrame:frameimg];
    [contactsButton setImage:contactsImg forState:UIControlStateNormal];
    
    [contactsButton addTarget:self action:@selector(clickedAddContacts)
             forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *contactsBarButton =[[UIBarButtonItem alloc] initWithCustomView:contactsButton];
    self.navigationItem.rightBarButtonItem = contactsBarButton;
}

-(void) clickedAddContacts
{
    // creating the picker
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	// place the delegate of the picker to the controll
	picker.peoplePickerDelegate = self;
	
	// showing the picker
	[self presentModalViewController:picker animated:YES];
	// releasing
//	[picker release];
}

-(void) customizeNavBar
{
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0], 
        UITextAttributeTextColor, 
      [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.9], 
        UITextAttributeTextShadowColor, 
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)], 
        UITextAttributeTextShadowOffset, 
      [GlobalSettings baseFont:22.0], 
        UITextAttributeFont, 
      nil]];
    
    UIImage *button30 = [UIImage imageNamed:@"button_textured_30.png"];
    UIImage *button24 = [UIImage imageNamed:@"button_textured_24.png"];
    [[UIBarButtonItem appearance] setBackgroundImage:button30 forState:UIControlStateNormal 
                                          barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:button24 forState:UIControlStateNormal 
                                          barMetrics:UIBarMetricsLandscapePhone];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8], 
      UITextAttributeTextColor, 
      [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8], 
      UITextAttributeTextShadowColor, 
      [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], 
      UITextAttributeTextShadowOffset, 
      [GlobalSettings baseFont:0.0], 
      UITextAttributeFont, 
      nil] 
    forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1], 
      UITextAttributeTextColor, 
      [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1], 
      UITextAttributeTextShadowColor, 
      [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], 
      UITextAttributeTextShadowOffset, 
      [GlobalSettings baseFont:0.0], 
      UITextAttributeFont, 
      nil] 
    forState:UIControlStateHighlighted];
    
    UIImage *buttonBack30 = [[UIImage imageNamed:@"button_back_textured_30"] 
                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
    UIImage *buttonBack24 = [[UIImage imageNamed:@"button_back_textured_24"] 
                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 5)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack30 
                                                      forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack24 
                                                      forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    self.navigationController.navigationBar.tintColor = NAVCOLOR;
    
    UIImage *NavigationPortraitBackground = [[UIImage imageNamed:@"denim.png"] 
                                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *NavigationLandscapeBackground = [[UIImage imageNamed:@"denim.png"] 
                                              resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [[UINavigationBar appearance] setBackgroundImage:NavigationPortraitBackground 
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:NavigationLandscapeBackground 
                                       forBarMetrics:UIBarMetricsLandscapePhone];
}

-(void) customizeTable 
{
    self.tableView.backgroundColor = [GlobalSettings backImage];
}

// Core Data Stuff

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Reminders" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"freq" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sectionIdentifier" cacheName:@"Master"];
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
    
    NSLog(@"FECTHED DATA :: %@", sortDescriptors);
    
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
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

// End Core Data Stuff

-(void) clearAllReminderDetails
{

}

// Picker Controller Callback Start

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self displayPerson:person];
    [self dismissModalViewControllerAnimated:YES];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
                                property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)displayPerson:(ABRecordRef)person 
{
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                    kABPersonFirstNameProperty);
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                     kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    } else {
        phone = @"[None]";
    }
    
    if (!self.detailViewController) {
        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    }
    
    self.detailViewController.name = name;
    self.detailViewController.phone = phone;
    self.detailViewController.time = [[NSDate alloc] init];
    self.detailViewController.frequency = @"3d";
    
    self.detailViewController.viewTitle = @"New Rmndr";
    
    [self insertNewObject:self.detailViewController];
    
    [self.navigationController pushViewController:self.detailViewController animated:YES];
    
}

// Picker Controller Callback End

// Core data Insert

- (void)insertNewObject:(DetailViewController *) detailViewController
{
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newManagedObject setValue:detailViewController.name forKey:@"name"];
    [newManagedObject setValue:detailViewController.phone forKey:@"phone"];
    [newManagedObject setValue:detailViewController.time forKey:@"time"];
    [newManagedObject setValue:detailViewController.frequency forKey:@"freq"];
    
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
}

// Core data Insert End

@end
