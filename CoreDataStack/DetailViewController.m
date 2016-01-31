//
//  DetailViewController.m
//  CoreDataStack
//
//  Created by MAXIME on 1/30/16.
//  Copyright © 2016 MAXIME. All rights reserved.
//

#import "DetailViewController.h"
#import "CoreDataManager.h"
#import "DataManager.h"

@interface DetailViewController ()
<
NSFetchedResultsControllerDelegate
>

@property (weak, nonatomic) IBOutlet UIImageView *gameImageView;
@property (weak, nonatomic) IBOutlet UILabel *gameNamelabel;

@property (strong, nonatomic) NSFetchedResultsController * gameFRC;

@end

@implementation DetailViewController

#pragma mark - Lifecycle
#pragma mark


-(void) loadGame: (Game*) game
{
    /* Configuring the FRC to the data source. Using KVO to prevent the UI, especially detail-type UIs which are often editable, from ever becoming des-synchronized with the underlying data. We dont want the user making edits on an object which no longer exists, and we dont want a user viewing a detail screen which is outdated.*/
    
    NSFetchRequest * request = [[NSFetchRequest alloc]initWithEntityName:@"Game"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"self = %@", game.objectID];
    
    self.gameFRC =  [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:[CoreDataManager sharedCoreDataManager].mainThreadContext sectionNameKeyPath:nil cacheName:nil];
    self.gameFRC.delegate = self;
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self loadScreen];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions
#pragma mark

/* Again, no hard-wired depencies between data-altering user input and interface updates, the interface updates are processed asynchronously from notification observers (FRC protocol).*/

- (IBAction)didPressDelete:(UIBarButtonItem *)sender
{
    Game * theGame = self.gameFRC.fetchedObjects [0];
    [[DataManager sharedDataManager] deleteRecordWithID:theGame.objectID];
}

#pragma mark - FetchedResultsControler delegate
#pragma mark



- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    switch (type)
    {
        case NSFetchedResultsChangeDelete: // The data source has been deleted, notify the master to let it unwind navigation (containment)
        {
            [self.navigationResponder unwindNavigation:self];
        }
            break;
        case NSFetchedResultsChangeUpdate:  // The data source has changes, update the screen not (not implemented in this sample)
        {
            [self loadScreen];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Helpers
#pragma mark


-(void) loadScreen
{
    [self.gameFRC performFetch:nil];
    Game * theGame = self.gameFRC.fetchedObjects [0];
    self.gameImageView.image = [UIImage imageNamed:theGame.name];
    self.gameNamelabel.text = theGame.name;
    
}



@end
