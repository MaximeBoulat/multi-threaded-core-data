//
//  CoreDataManager.m
//  CoreDataStack
//
//  Created by MAXIME on 1/29/16.
//  Copyright © 2016 MAXIME. All rights reserved.
//

#import "CoreDataManager.h"


typedef NS_ENUM(NSInteger, operationType){
    OperationTypeRead,
    OperationTypeWrite
};


@interface CoreDataManager()

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSOperationQueue * coreDataQueue;

@end

@implementation CoreDataManager

#pragma mark - lifecycle
#pragma mark


+(CoreDataManager *) sharedCoreDataManager
{
    static CoreDataManager * sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [CoreDataManager new];
    });
    
    return sharedInstance;
    
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self managedObjectContext]; // This creates the store, the coordinator and the main thread context
        self.coreDataQueue = [NSOperationQueue new];
        self.coreDataQueue.maxConcurrentOperationCount = 5;
    }
    return self;
}

#pragma mark - Public methods
#pragma mark

-(void) coordinateWriting:(CoreDataSerializedBlock)block
{
    [self serializeTransaction:block protected:YES];
}

-(void) coordinateReading:(CoreDataSerializedBlock)block
{
     [self serializeTransaction:block protected:NO];
}






#pragma mark - Helpers
#pragma mark



-(NSManagedObjectContext *) backgroundContext
{
    NSManagedObjectContext * context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = self.mainThreadContext;
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    
    return context ;
}


-(void) serializeTransaction:(CoreDataSerializedBlock) block protected: (BOOL) protected
{
    
    /* This is where the magic happens. 
     
     All transactions are processed against a on-demand background child context which is instantiated for the lifetime and the transaction and then saved and discarded. The save is propagated to to the parent (the main thread context) so that the changes surface to the store.
     
     All write/protected operations are 'barriered' through dependencies defined when the operation is added to the queue (writes will just be dependent on all pending operations, and reads will be dependents only on those pending operations in the queue which are writes).
     
     These conditions met, transactions, be them reads or writes, will never be faced with a context which is out of sync with the store. Since only writes can modify the store, and writes will only get servered with a context once the previous write has completed and its changes are surfaced to the main thread context, from which the new work context is drawn.
     
     */
    
    NSBlockOperation * coreDataOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSManagedObjectContext * context = [self backgroundContext];
        
        __block __weak NSManagedObjectContext * weakContext = context;
        
        
        [context performBlockAndWait:^
         {
             __strong NSManagedObjectContext * strongContext = weakContext;
             
             block(strongContext);
             
             [strongContext save:nil];
             
             __block __weak NSManagedObjectContext * weakParentContext = strongContext.parentContext;
             
             [strongContext.parentContext performBlockAndWait:^{
                 
                 [weakParentContext save:nil];
             }];
         }];
        
    }];
    
    if (protected)  // enforcing the dependencies
    {
        coreDataOperation.name = [NSString stringWithFormat:@"%ld", (long)OperationTypeWrite];
    }
    else
    {
        coreDataOperation.name = [NSString stringWithFormat:@"%ld", (long)OperationTypeRead];
    }
    
    
    @synchronized(self)  //Synchronizing access to the queue! Multiple threads could be in there at the same time
    {
        for (NSBlockOperation * operation in self.coreDataQueue.operations)
        {
             // enforcing the dependencies
            if (protected)
            {
                 [coreDataOperation addDependency:operation];
            }
            else if ([operation.name isEqualToString:[NSString stringWithFormat:@"%ld", (long)OperationTypeWrite]])
            {
                [coreDataOperation addDependency:operation];
            }
            
        }
        
        [self.coreDataQueue addOperation:coreDataOperation];
    }

    
}

#pragma mark - Boilerplate code
#pragma mark

@synthesize mainThreadContext = _mainThreadContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.projectbroadway.CoreDataStack" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataStack" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataStack.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_mainThreadContext != nil) {
        return _mainThreadContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _mainThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainThreadContext setPersistentStoreCoordinator:coordinator];
    return _mainThreadContext;
}




@end
