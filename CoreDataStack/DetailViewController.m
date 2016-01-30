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
    
    NSFetchRequest * request = [[NSFetchRequest alloc]initWithEntityName:@"Game"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"self = %@", game.objectID];
    
    self.gameFRC =  [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:[CoreDataManager sharedCoreDataManager].mainThreadContext sectionNameKeyPath:nil cacheName:nil];
    self.gameFRC.delegate = self;
}


- (void)viewDidLoad
{
    
    [self.gameFRC performFetch:nil];
    
    Game * theGame = self.gameFRC.fetchedObjects [0];
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.gameImageView.image = [UIImage imageNamed:theGame.name];
    self.gameNamelabel.text = theGame.name;
    


    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions
#pragma mark


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
        case NSFetchedResultsChangeDelete:
        {
            [self.navigationResponder unwindNavigation:self];
        }
            break;
        default:
            break;
    }
}






@end
