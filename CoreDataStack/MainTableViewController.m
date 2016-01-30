//
//  MainTableViewController.m
//  CoreDataStack
//
//  Created by MAXIME on 1/29/16.
//  Copyright © 2016 MAXIME. All rights reserved.
//

#import "MainTableViewController.h"

#import "DataManager.h"
#import "CoreDataManager.h"

#import "Player.h"
#import "Platform.h"

#import "UserCell.h"
#import "PlatformCell.h"
#import "GameCell.h"
#import "DetailViewController.h"


#define STRESS_TEST 0


@interface MainTableViewController ()
<
NSFetchedResultsControllerDelegate,
GamePurchaseProtocol,
NavigationResponder
>


@property (nonatomic, strong) NSFetchedResultsController * dataSource;
@property (nonatomic, strong) NSManagedObject * relationshipObject;

- (IBAction)didPressPlusButton:(UIBarButtonItem *)sender;

@end

@implementation MainTableViewController

#pragma mark - Lifecycle
#pragma mark

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
        self.currentMode = TableModeUser;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    /* All the lists are synchronized with the data in the core data store through the use of NSFetchedResultsController configured with the approproate fetch request. There is no hard depency between user input and UI updates. The user input (delete row/add record) triggers some data activity (in the DataManager layer). The NSFetchedResultsControllers delegate methods in turn notify the UI of changes in the data layer.
     The only exception is the Store list, which is populated with a traditional array of non-persistent objects
     */
    
    NSFetchRequest * request;
    
    switch (self.currentMode)
    {
        case TableModeUser:
        {
            self.navigationItem.leftBarButtonItem = nil;
            self.title = @"User";
            request = [[NSFetchRequest alloc]initWithEntityName:@"Player"];
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
            
        }
            break;
        case TableModePlatform:
        {
            self.navigationItem.leftBarButtonItem = nil;
            self.title = @"Platforms";
            request = [[NSFetchRequest alloc]initWithEntityName:@"Platform"];
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
            request.predicate =  [NSPredicate predicateWithFormat:@"player == %@", self.relationshipObject];

        }
            break;
        case TableModeGame:
        {
            self.navigationItem.leftBarButtonItem = nil;
            self.title = @"Games";
            request = [[NSFetchRequest alloc]initWithEntityName:@"Game"];
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
            request.predicate = [NSPredicate predicateWithFormat:@"platform == %@", self.relationshipObject];

        }
            break;
        case TableModeStore:
        {
            self.navigationItem.rightBarButtonItem = nil;
            self.title = @"GameStop";
        }
            break;
        default:
            self.navigationItem.leftBarButtonItem = nil;
            break;
    }

    
    if (self.currentMode != TableModeStore)
    {
        // Prepare the data source
        
        self.dataSource = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:[CoreDataManager sharedCoreDataManager].mainThreadContext sectionNameKeyPath:nil cacheName:nil];
        self.dataSource.delegate = self;
        
        [self.dataSource performFetch:nil];
    }

    
}


#pragma mark - table view
#pragma mark

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (self.currentMode == TableModeStore)
    {
        return [DataManager sharedDataManager].gamesForSale.count;
    }
    else
    {
        return self.dataSource.fetchedObjects.count;
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     
    UITableViewCell * returnCell;
    
    
    /* The table's data source is always a NSFetchedResultsController fetched objects, except in the case of the Store list, where it is a standard array which resides in the Datamanager(could have pointed to by the view controller to make it more MVC but since it's in essence static, I'd rather not have multiple references to it) */
    
    switch (self.currentMode)
    {
        case TableModeUser:
        {
            UserCell *cell = (UserCell*) [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
            Player * player = self.dataSource.fetchedObjects [indexPath.row];
            cell.userNameLabel.text = player.name;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            returnCell = cell;
        }
            break;
        case TableModePlatform:
        {
            PlatformCell * cell = (PlatformCell *) [tableView dequeueReusableCellWithIdentifier:@"PlatformCell" forIndexPath:indexPath];
            Platform * platform = self.dataSource.fetchedObjects [indexPath.row];
            cell.platformNameLabel.text = platform.name;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            returnCell = cell;
            
        }
            break;
        case TableModeGame:
        {
            GameCell * cell = (GameCell *) [tableView dequeueReusableCellWithIdentifier:@"GameCell" forIndexPath:indexPath];
             Game * game = self.dataSource.fetchedObjects [indexPath.row];
            cell.gameNameLabel.text = game.name;
            cell.gameImageView.image = [UIImage imageNamed:game.name];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            returnCell = cell;
        }
            break;
        case TableModeStore:
        {
            GameCell * cell = (GameCell *) [tableView dequeueReusableCellWithIdentifier:@"GameCell" forIndexPath:indexPath];
            Game * game = [DataManager sharedDataManager].gamesForSale [indexPath.row];
            cell.gameNameLabel.text = game.name;
            cell.gameImageView.image = [UIImage imageNamed:game.name];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            returnCell = cell;
        }
            break;
            
        default:
            break;
    }
    
    
    return returnCell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentMode == TableModeStore)
    {
        return NO;
    }
    else
    {
        return YES;
    }

}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSManagedObject * data = self.dataSource.fetchedObjects [indexPath.row];
        [[DataManager sharedDataManager]deleteRecordWithID:data.objectID];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /* All lists provide lateral navigation on the splitviewcontroller's master pane except for:
     *the games list which will populate the split's detail pane with game details.
     *the store list which invokes its delegate to execute a data transaction and modal dismissal (see didPickGame:)
     The subsequent lists need a reference called relationshipObject on which to predicate their FetchedResultsController's request. For Platforms it is a Player, for Games it is a Platform. Those relationships are enforced in the data layer and in the database schema.
     The currentMode variable provides for state under which to configure its appesarance and behavior*/
    
    switch (self.currentMode)
    {
        case TableModeUser:
        {
            MainTableViewController * viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"MainTableVC"];
            viewController.relationshipObject = self.dataSource.fetchedObjects[indexPath.row];
            viewController.currentMode = TableModePlatform;
                [self showViewController:viewController sender:self];
        }
            break;
        case TableModePlatform:
        {
                        MainTableViewController * viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"MainTableVC"];
            viewController.currentMode = TableModeGame;
            viewController.relationshipObject = self.dataSource.fetchedObjects[indexPath.row];
                [self showViewController:viewController sender:self];
        }
            break;
        case TableModeGame:
        {
            UINavigationController * detailNav = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"DetailNav"];
            DetailViewController * detail = detailNav.viewControllers [0];
            detail.navigationResponder = self;
            [detail loadGame:self.dataSource.fetchedObjects[indexPath.row]];
            [self showDetailViewController:detailNav sender:self];
            
        }
            break;
        case TableModeStore:
        {
            [self.gamePurchaseDelegate didPickGame:[DataManager sharedDataManager].gamesForSale [indexPath.row]];
        }
            break;
        default:
            break;
    }
    

    
}



#pragma mark - actions
#pragma mark

- (IBAction)unwindModal:(UIStoryboardSegue *)unwindSegue
{
    
    // This is apparently mandatory to implement the unwind (Exit) segue in the storyboard
}

 

- (IBAction)didPressPlusButton:(UIBarButtonItem *)sender
{
    
    /* Pressing the '+' button from the Games list invokes the Store screen (where user can 'purchase' games to add them to their personal inventory. Pressing the '+' button anywhere else displays a alertview from a record can be inserted with a custom name.*/
    
    if (self.currentMode == TableModeGame)
    {
        if (STRESS_TEST)
        {
            if ([DataManager sharedDataManager].stressing)
            {
                [[DataManager sharedDataManager] stopStressTest];
            }
            else
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                    
                    [[DataManager sharedDataManager] startStressTestWithRelationhip:self.relationshipObject.objectID];
                });
            }
        }
        else
        {
            UINavigationController * storeNav = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"MainTableNav"];
            
            MainTableViewController * store = storeNav.viewControllers [0];
            store.currentMode = TableModeStore;
            store.gamePurchaseDelegate = self;
            
            [self presentViewController:storeNav animated:YES completion:nil];
        }
        

    }
    else
    {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"Enter name to add" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * add = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self addRecordWithName:alert.textFields[0].text];
            
        }];
        
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:add];
        [alert addAction:cancel];
        
        [alert addTextFieldWithConfigurationHandler:nil];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
     
}


#pragma mark - NSFetchedResultsController protocol
#pragma mark



// This is boilerplate NSFetchedResultsControllerDelegate implementation, keeps the table synchronized with the underlying data

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}



- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}



- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        case NSFetchedResultsChangeMove:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        default:
            break;
    }
}


#pragma mark - Game Sale protocol
#pragma mark

// The store list is reporting to the games list that the user has purchased a game. Both are instances of the same class.

- (void) didPickGame: (GameForSale *) game
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[DataManager sharedDataManager] insertGamePurchase:game relationship:self.relationshipObject.objectID];
}


#pragma mark - NavigationResponder
#pragma mark

// THe detail pane is reporting to the master that the data source it's feeding from has been deleted. Letting the master make decisions about detail pane uypdates.

-(void) unwindNavigation: (UIViewController *) viewController
{
    
    // Master will populate the detail pane with the empty state screen
    UIViewController * emptyState =  [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"EmptyStateVC"];
    [self showDetailViewController:emptyState sender:self];
    
}


#pragma mark - Helpers
#pragma mark

// helper function to interface with the Data layer

- (void) addRecordWithName: (NSString*) name
{
    
    if (name)
    {
        switch (self.currentMode)
        {
            case TableModeUser:
                [[DataManager sharedDataManager] insertUserWithName:name];
                
                break;
            case TableModePlatform:
                [[DataManager sharedDataManager] insertPlatformWithName:name relationship: self.relationshipObject.objectID];
                
                break;
                
            default:
                break;
        }
    }
    
}



@end
