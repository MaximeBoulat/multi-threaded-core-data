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


@property (nonatomic, strong) NSArray * gamesForSale;

+ (DataManager *) sharedDataManager;

- (void) insertUserWithName: (NSString *) name;
- (void) insertPlatformWithName: (NSString *) name relationship:(NSManagedObjectID *)user;


- (void) deleteRecordWithID: (NSManagedObjectID *) objectId;

- (void) insertGamePurchase: (GameForSale *) game relationship: (NSManagedObjectID *) platform;


@end
