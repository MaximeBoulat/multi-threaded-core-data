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

@protocol GamePurchaseProtocol <NSObject>

@optional
- (void) didPickGame: (GameForSale *) game;

@end

@protocol NavigationResponder <NSObject>

@optional
-(void) unwindNavigation: (UIViewController *) viewController;

@end


@interface MainTableViewController : UITableViewController


@property (nonatomic, assign) TableMode currentMode;
@property (nonatomic, weak) id <GamePurchaseProtocol> gamePurchaseDelegate;


@end
