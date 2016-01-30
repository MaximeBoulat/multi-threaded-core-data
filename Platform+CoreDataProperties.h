//
//  Platform+CoreDataProperties.h
//  CoreDataStack
//
//  Created by MAXIME on 1/30/16.
//  Copyright © 2016 MAXIME. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Platform.h"
#import "Player.h"
#import "Game.h"

NS_ASSUME_NONNULL_BEGIN

@interface Platform (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Game *> *games;
@property (nullable, nonatomic, retain) Player *player;

@end

@interface Platform (CoreDataGeneratedAccessors)

- (void)addGamesObject:(Game *)value;
- (void)removeGamesObject:(Game *)value;
- (void)addGames:(NSSet<Game *> *)values;
- (void)removeGames:(NSSet<Game *> *)values;

@end

NS_ASSUME_NONNULL_END
