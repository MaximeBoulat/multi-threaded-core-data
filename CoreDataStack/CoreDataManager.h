//
//  CoreDataManager.h
//  CoreDataStack
//
//  Created by MAXIME on 1/29/16.
//  Copyright © 2016 MAXIME. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void(^CoreDataSerializedBlock)(NSManagedObjectContext *context);


/* This Core data implementation offers two major advantages:
 * enforces thread safety when core data transactions are requested from the background
 * serialization of core data transactions using dependencies and a private queue to prevent multiple transactions from modifying the same records concurrently
 */

@interface CoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *mainThreadContext; // This main thread context is leveraged by the NSFetchedResultsControllers in the UI. It is not recommended to use it to write to Core Data, since doing so would bypass the serialization enforced in coordinateWriting/coordinateReading.
@property (nonatomic, strong) NSOperationQueue * coreDataQueue;

+(CoreDataManager *) sharedCoreDataManager;


// The coordinateWriting API will 'barrier' the block parameter, preventing it from running concurrently to other blocks, the source param is for debugging.
-(void) coordinateWriting:(CoreDataSerializedBlock)block identifier: (NSString *) source;

// Read transactions are harmless, therefore they are not 'barriered' in the queue, however they must be prevented from running concurrently to write transactions
-(void) coordinateReading:(CoreDataSerializedBlock)block identifier: (NSString *) source;




@end


@interface CoreDataOperation : NSBlockOperation



@end


@interface CoreDataContext : NSManagedObjectContext

@end
