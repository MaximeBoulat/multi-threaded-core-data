//
//  GamesManager.h
//  CoreDataStack
//
//  Created by MAXIME on 1/29/16.
//  Copyright © 2016 MAXIME. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GameForSale.h"



@interface DataManager : NSObject


// The data manager is a proxy to all core data logic, so as to decouple it from all the UI logic.


@property (nonatomic, strong) NSArray * gamesForSale;
@property (nonatomic, assign) BOOL stressing;

+ (DataManager *) sharedDataManager;

- (void) insertUserWithName: (NSString *) name;
- (void) insertPlatformWithName: (NSString *) name relationship:(NSManagedObjectID *)user;
- (void) insertGamePurchase: (GameForSale *) game relationship: (NSManagedObjectID *) platform;

- (void) deleteRecordWithID: (NSManagedObjectID *) objectId;


-(void) startStressTestWithRelationhip: (NSManagedObjectID *) user;
-(void) stopStressTest;




@end
