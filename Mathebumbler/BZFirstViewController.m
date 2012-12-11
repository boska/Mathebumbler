//
//  BZFirstViewController.m
//  Mathebumbler
//
//  Created by Boska on 12/11/30.
//  Copyright (c) 2012年 Boska. All rights reserved.
//

#import "BZFirstViewController.h"
#import "AFJSONRequestOperation.h"
#import "BzQuotes.h"
#import "BZAppDelegate.h"
#import "Entity.h"
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface BZFirstViewController ()

@end

@implementation BZFirstViewController
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UINavigationBar appearance] setTintColor:[UIColor brownColor]];
        [self.view setBackgroundColor:UIColorFromRGB(0x7ACEFF)];
}
- (IBAction)authButtonAction:(id)sender{
    BZAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    // The user has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    [appDelegate openSessionWithAllowLoginUI:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    BZAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate getFBid];
       //[self.managedObjectContext save:nil];

}
- (void)loadQuotes
{
    
}
- (IBAction)dissmissKeyboard:(id)sender
{
    BZAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Entity" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (Entity *e in fetchedObjects) {
        NSLog(@"%@ %@ %@ %@", [e valueForKey:@"subject1"],[e valueForKey:@"subject2"],[e valueForKey:@"subject3"],[e valueForKey:@"subject4"]);

    }
}
@end
