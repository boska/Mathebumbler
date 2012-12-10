//
//  ListViewController.h
//  Mathebumbler
//
//  Created by Boska on 12/12/10.
//  Copyright (c) 2012年 Boska. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UITableViewController <NSFetchedResultsControllerDelegate , UITableViewDataSource,UITableViewDelegate>{
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableArray *fetchObjects;
@property (nonatomic, strong) IBOutlet UITableView *myTableView;

@end
