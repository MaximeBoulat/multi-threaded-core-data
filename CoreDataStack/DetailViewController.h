//
//  DetailViewController.h
//  CoreDataStack
//
//  Created by MAXIME on 1/30/16.
//  Copyright © 2016 MAXIME. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainTableViewController.h"
#import "Game.h"


@interface DetailViewController : UIViewController

@property (nonatomic, weak) id <NavigationResponder> navigationResponder;


/* This view controller is also powered by NSFetchedResultsController, even though it only feeds off a single record
 The loadGame method will configure its FRC for the record.*/
-(void) loadGame: (Game*) game;


@end
