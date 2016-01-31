//
//  MainTableViewController.h
//  CoreDataStack
//
//  Created by MAXIME on 1/29/16.
//  Copyright © 2016 MAXIME. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameForSale.h"




typedef NS_ENUM(NSInteger, TableMode) {
    TableModeUser,
    TableModePlatform,
    TableModeGame,
    TableModeStore
};



/* Instances of this table view controller will be used for all 4 types of lists displayed int the app.
 In the case of the Store list, an instance of this view controller (TableModeGame type)  will be the delegate of another instance of this view controller (TableModeStore type) and will conform to GamePurchaseProtocol.*/



@protocol GamePurchaseProtocol <NSObject>

@optional
- (void) didPickGame: (GameForSale *) game;

@end


/*This protocol provides a channel through which the splitViewController master can make decisions about navigation when the detail pane reports that its data source has ceased existing.*/

@protocol NavigationResponder <NSObject>

@optional
-(void) unwindNavigation: (UIViewController *) viewController;

@end


@interface MainTableViewController : UITableViewController


@property (nonatomic, assign) TableMode currentMode;
@property (nonatomic, weak) id <GamePurchaseProtocol> gamePurchaseDelegate;

- (UIViewController *) viewControllerForSplitViewExpansion;


@end
