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


typedef NSString* (^MyTestBlock)(int x);

@interface CoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *mainThreadContext;


+(CoreDataManager *) sharedCoreDataManager;
-(void) tryingOutBlockWithBlock: (MyTestBlock) block;


-(void) coordinateWriting:(CoreDataSerializedBlock)block;
-(void) coordinateReading:(CoreDataSerializedBlock)block;




@end
