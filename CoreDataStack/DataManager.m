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
    }
    return self;
}


#pragma mark - Utilities
#pragma mark

- (void) insertUserWithName: (NSString *) name
{
    
    [[CoreDataManager sharedCoreDataManager] coordinateWriting:^(NSManagedObjectContext *context) {
        
        Player * newPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:context];
        newPlayer.name = name;
        
    }];
}


- (void) insertPlatformWithName: (NSString *) name relationship:(NSManagedObjectID *)user
{
    [[CoreDataManager sharedCoreDataManager] coordinateWriting:^(NSManagedObjectContext *context) {
        
        Platform * newPlatform = [NSEntityDescription insertNewObjectForEntityForName:@"Platform" inManagedObjectContext:context];
        newPlatform.name = name;
        newPlatform.player = [context  existingObjectWithID:user error:nil];
        
    }];
}

- (void) insertGamePurchase: (GameForSale *) game relationship: (NSManagedObjectID *) platform
{
    [[CoreDataManager sharedCoreDataManager] coordinateWriting:^(NSManagedObjectContext *context) {
        
        Game * newgame = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:context];
        newgame.name = game.name;
        newgame.platform = [context  existingObjectWithID:platform error:nil];
        
    }];
    
    
}

- (void) deleteRecordWithID:(NSManagedObjectID *)objectId
{
      [[CoreDataManager sharedCoreDataManager] coordinateWriting:^(NSManagedObjectContext *context) {
          
          NSManagedObject * record = [context existingObjectWithID:objectId error:nil];
          [context deleteObject:record];
          
      }];
    
    
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
