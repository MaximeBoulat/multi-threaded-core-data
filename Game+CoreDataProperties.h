//
//  Game+CoreDataProperties.h
//  CoreDataStack
//
//  Created by MAXIME on 1/30/16.
//  Copyright © 2016 MAXIME. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Game.h"
#import "Platform.h"

NS_ASSUME_NONNULL_BEGIN

@interface Game (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) Platform *platform;

@end

NS_ASSUME_NONNULL_END
