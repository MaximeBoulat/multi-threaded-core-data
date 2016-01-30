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


@property (nonatomic, strong) NSOperationQueue * stressTestQueue;




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
        [self prepareGameStopInventory];
        self.stressTestQueue = [NSOperationQueue new];
        self.stressTestQueue.maxConcurrentOperationCount = 20;
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
          [context deleteObject:record];
          
      } identifier:@"deleteRecordWithID"];
    
    
}





-(void) startStressTestWithRelationhip: (NSManagedObjectID *) user
{
    @synchronized(self.stressTestQueue)
    {
        self.stressing = YES;
    }

    
    
    void (^writeBlock) (GameForSale*)= ^(GameForSale * game) {
        
        [self insertGamePurchase:game relationship:user];
        
    };
    
    
    void (^readBlock) (void) = ^{
        
        [[CoreDataManager sharedCoreDataManager] coordinateReading:^(NSManagedObjectContext *context) {
            
            NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Game"];
            
           NSArray * games = [context executeFetchRequest:request error:nil];
            
            
            for (Game * game in games)
            {
                NSLog(@"Found game with name: %@", game.name);
            }
            
        } identifier:@"readBlock"];
        
    };
    
    
    void (^deleteBlock) (void) = ^{
        
              [[CoreDataManager sharedCoreDataManager] coordinateWriting:^(NSManagedObjectContext *context) {
                 
                  // Delete random ranges of objects
                  
                  NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Game"];
                  NSArray * games = [context executeFetchRequest:request error:nil];
                  
                  NSInteger index = arc4random() %games.count;
                  
                  for (int i = 0; i<index; i++)
                  {
                      Game * game = games[i];
                      [context deleteObject:game];
                  }
                  
                  
              }identifier:@"deleteBlock"];
        
    };
    
    
    while (self.stressing)
    {
        
        [self.stressTestQueue addOperationWithBlock:^{
            
            NSInteger operationtype = arc4random() %3;
            
            switch (operationtype) {
                case StressOperationTypeInsert: // insert 20 random records
                {
                    int count = 0;
                    
                    while (count <= 20)
                    {
                        count ++;
                        
                        NSInteger gameIndex = arc4random() %self.gamesForSale.count;
                        
                        writeBlock ((GameForSale*) self.gamesForSale[gameIndex]);
                        
                    }
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
            
        }];
 
         
        [NSThread sleepForTimeInterval:1.0f];
        
    }

}

 


-(void) stopStressTest
{
    
    @synchronized(self.stressTestQueue)
    {
        self.stressing = NO;
    }

    
    [self.stressTestQueue cancelAllOperations];
    
}




#pragma mark - Helpers
#pragma mark
    
-(void) prepareGameStopInventory
{
    GameForSale * uncharted = [GameForSale new];
    uncharted.name = @"Uncharted";
    
    GameForSale * wolfenstein = [GameForSale new];
    wolfenstein.name = @"Wolfenstein";
    
    GameForSale * lastOfUs = [GameForSale new];
    lastOfUs.name = @"LastOfUs";
    
    GameForSale * godOfWar = [GameForSale new];
    godOfWar.name = @"GodOfWar";
    
    GameForSale * metalGear = [GameForSale new];
    metalGear.name = @"MetalGear";
    
    GameForSale * rainbowSix = [GameForSale new];
    rainbowSix.name = @"RainbowSix";
    
    GameForSale * battlefield = [GameForSale new];
    battlefield.name = @"Battlefield";
    
    GameForSale * farCry = [GameForSale new];
    farCry.name = @"FarCry";
    
    GameForSale * witcher = [GameForSale new];
    witcher.name = @"Witcher";
    
    GameForSale * metro = [GameForSale new];
    metro.name = @"Metro";
    
    self.gamesForSale = @[uncharted,
                          wolfenstein,
                          lastOfUs,
                          godOfWar,
                          metalGear,
                          rainbowSix,
                          battlefield,
                          farCry,
                          witcher,
                          metro];

    
}




@end
