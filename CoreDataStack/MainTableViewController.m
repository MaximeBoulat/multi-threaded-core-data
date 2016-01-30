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
    
    NSFetchRequest * request;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

     
     if ([segue.identifier isEqualToString:@"PresentStore"]) 
     {
         MainTableViewController * store = ((UINavigationController*)segue.destinationViewController).viewControllers[0];
         store.currentMode = TableModeStore;
         
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
    
     

    
    // Configure the cell...
    
    return returnCell;
}



// Override to support conditional editing of the table view.
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



// Override to support editing the table view .
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
    
    
}



- (IBAction)didPressPlusButton:(UIBarButtonItem *)sender
{
    if (self.currentMode == TableModeGame)
    {
        UINavigationController * storeNav = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"MainTableNav"];
        
        MainTableViewController * store = storeNav.viewControllers [0];
        store.currentMode = TableModeStore;
        store.gamePurchaseDelegate = self;
        
        [self presentViewController:storeNav animated:YES completion:nil];
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

- (void) didPickGame: (GameForSale *) game
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[DataManager sharedDataManager] insertGamePurchase:game relationship:self.relationshipObject.objectID];
}


#pragma mark - NavigationResponder
#pragma mark


-(void) unwindNavigation: (UIViewController *) viewController
{
    UIViewController * emptyState =  [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"EmptyStateVC"];
    
    [self showDetailViewController:emptyState sender:self];
    
}


#pragma mark - Helpers
#pragma mark


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
