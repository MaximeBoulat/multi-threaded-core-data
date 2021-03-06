//
//  GamesManager.m
//  CoreDataStack
//
//  Created by MAXIME on 1/29/16.
//  Copyright © 2016 MAXIME. All rights reserved.
//

#import "DataManager.h"
#import "CoreDataManager.h"

#import "Player.h"
#import "Platform.h"
#import "Game.h"


@interface DataManager ()




@end

typedef NS_ENUM(NSInteger, StressOperationType) {
    StressOperationTypeRead,
    StressOperationTypeInsert,
    StressOperationTypeDelete
};

@implementation DataManager

#pragma mark - Lifecycle
#pragma mark


+ (DataManager *) sharedDataManager
{
    static DataManager * sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
       
        sharedInstance = [DataManager new];
        
    });
    
    return sharedInstance;
    
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.gamesForSale = [self prepareGameStopInventory];

    }
    return self;
}


#pragma mark - Public methods
#pragma mark

- (void) insertUserWithName: (NSString *) name
{
    
    [[CoreDataManager sharedCoreDataManager] coordinateWriting:^(NSManagedObjectContext *context) {
        
        Player * newPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:context];
        newPlayer.name = name;
        
    }identifier:@"insertUserWithName"];
}


- (void) insertPlatformWithName: (NSString *) name relationship:(NSManagedObjectID *)user
{
    [[CoreDataManager sharedCoreDataManager] coordinateWriting:^(NSManagedObjectContext *context) {
        
        Platform * newPlatform = [NSEntityDescription insertNewObjectForEntityForName:@"Platform" inManagedObjectContext:context];
        newPlatform.name = name;
        newPlatform.player = [context  existingObjectWithID:user error:nil];
        
    }identifier:@"insertPlatformWithName"];
}

- (void) insertGamePurchase: (GameForSale *) game relationship: (NSManagedObjectID *) platform
{
    [[CoreDataManager sharedCoreDataManager] coordinateWriting:^(NSManagedObjectContext *context) {
        
        Game * newgame = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:context];
        newgame.name = game.name;
        newgame.platform = [context  existingObjectWithID:platform error:nil];
        
    }identifier:@"insertGamePurchase"];
    
    
}

- (void) deleteRecordWithID:(NSManagedObjectID *)objectId
{
      [[CoreDataManager sharedCoreDataManager] coordinateWriting:^(NSManagedObjectContext *context) {
          
          NSManagedObject * record = [context existingObjectWithID:objectId error:nil];
          
          if (record)
          {
              [context deleteObject:record];
          }

      } identifier:@"deleteRecordWithID"];
    
    
}


 


-(void) startStressTestWithRelationhip: (NSManagedObjectID *) platform
{
    
    /* A while loop will randomly pick one of three transactions for every interation:
     - Delete a random range of records
     - Add 20 random records
     - Fetch and read the records 4 times
     
     */
     
    void (^writeBlock) (void)= ^ {
        
        
        [[CoreDataManager sharedCoreDataManager] coordinateWriting:^(NSManagedObjectContext *context) {
            
            int count = 0;
            
            while (count <= 20)
            {
                count ++;
                
                NSInteger gameIndex = arc4random() %self.gamesForSale.count;
                GameForSale * game = self.gamesForSale [ gameIndex];
                Game * newgame = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:context];
                newgame.name = game.name;
                newgame.platform = [context  existingObjectWithID:platform error:nil];
                
                
            }
            
        } identifier:@"writeBlock"];
        
    };
    
    
    void (^readBlock) (void) = ^{
        
        [[CoreDataManager sharedCoreDataManager] coordinateReading:^(NSManagedObjectContext *context) {
            
            NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Game"];
            
           NSArray * games = [context executeFetchRequest:request error:nil];
            
            
            for (Game * game in games)
            {
                NSString * name = game.name;  // This is intentionally not used, only purpose is to fire a fault
            }
            
        } identifier:@"readBlock"];
        
    };
     
    
    void (^deleteBlock) (void) = ^{
        
              [[CoreDataManager sharedCoreDataManager] coordinateWriting:^(NSManagedObjectContext *context) {
                 
                  // Delete random ranges of objects
                  
                  NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Game"];
                  NSArray * games = [context executeFetchRequest:request error:nil];
                  
                  if (games.count)
                  {
                      NSInteger index = arc4random() %games.count;
                      
                      for (int i = 0; i<index; i++)
                      {
                          Game * game = games[i];
                          [context deleteObject:game];
                      }
                  }

                  
              }identifier:@"deleteBlock"];
        
    };
    
    
    while (self.stressing)
    {
		
		// Dont let the queue mushroom
		if ([CoreDataManager sharedCoreDataManager].coreDataQueue.operationCount > [CoreDataManager sharedCoreDataManager].coreDataQueue.maxConcurrentOperationCount) {
			
			[NSThread sleepForTimeInterval:0.1];
		}
            
            NSInteger operationtype = arc4random() %3;
            
            switch (operationtype) {
                case StressOperationTypeInsert: // insert 20 random records
                {
                    writeBlock ();
                }
                    break;
                case StressOperationTypeDelete: // delete random range of records
                {
                    
                    deleteBlock();
                    
                }
                    break;
                case StressOperationTypeRead: // Attempt to read the records
                {
                    
                    int count = 0;
                    
                    while (count <= 4)
                    {
                        count ++;
                        readBlock();
                    }
                    
                }
                    break;
                    
                default:
                    break;
            }
		
    }
	
	
	    [[CoreDataManager sharedCoreDataManager].coreDataQueue cancelAllOperations];
}



#pragma mark - Helpers
#pragma mark
    
-(NSArray *) prepareGameStopInventory
{

    NSMutableArray * games = [NSMutableArray new];
    
    
    NSString * jsonString = @"[\n"
    "                          {\"name\": \"Uncharted\"},"
    "                          {\"name\": \"Wolfenstein\"},"
    "                          {\"name\": \"LastOfUs\"},"
    "                          {\"name\": \"GodOfWar\"},"
    "                          {\"name\": \"MetalGear\"},"
    "                          {\"name\": \"RainbowSix\"},"
    "                          {\"name\": \"Battlefield\"},"
    "                          {\"name\": \"FarCry\"},"
    "                          {\"name\": \"Witcher\"},"
    "                          {\"name\": \"Metro\"}"
    "]";
    
    NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError * error = nil;
    NSArray * jSon = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    
    for (NSDictionary * dict in jSon)
    {
        GameForSale * newGame = [GameForSale new];
        newGame.name = dict [@"name"];
        [games addObject:newGame];
 
    }
    
    /*
    
    NSData * jsonData2 = [NSJSONSerialization dataWithJSONObject:jSon options:kNilOptions error:nil];
    NSString * jsonString2 = [[NSString alloc]initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    
     */
    
    return [NSArray arrayWithArray:games];

}




@end


@implementation DataManagerOperation

- (void)dealloc
{
  //  NSLog(@"DataManagerOperation deallocating");
    
}

@end
