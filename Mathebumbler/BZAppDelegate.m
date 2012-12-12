//
//  BZAppDelegate.m
//  Mathebumbler
//
//  Created by Boska on 12/11/30.
//  Copyright (c) 2012年 Boska. All rights reserved.
//

#import "BZAppDelegate.h"
#import <CoreData/CoreData.h>
#import "Entity.h"
#import "AFJSONRequestOperation.h"
@implementation BZAppDelegate
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;
@synthesize managedObjectModel;
NSString *const FBSessionStateChangedNotification =@"boska.mathebumbler:FBSessionStateChangedNotification";
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSession.activeSession handleDidBecomeActive];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [FBSession.activeSession close];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"%@",session.accessToken);
                [[NSUserDefaults standardUserDefaults] setObject:session.accessToken forKey:@"fb_access_token"];
                [[NSUserDefaults standardUserDefaults] setObject:session.expirationDate forKey:@"fb_exp_date"];
                
                [FBRequestConnection startForMeWithCompletionHandler:
                 ^(FBRequestConnection *connection, id result, NSError *error)
                 {
                     NSLog(@"facebook id: %@", [result valueForKey:@"id"]);
                     [[NSUserDefaults standardUserDefaults] setObject:[result valueForKey:@"id"] forKey:@"fb_id"];

                 }];

            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}
//Explicitly write Core Data accessors
- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"mathebumbler.sqlite"]];
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    						 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    						 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:options error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    return [FBSession openActiveSessionWithReadPermissions:nil
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}
-(void)getFBid
{
}
-(AFJSONRequestOperation *)loadQuotesFromTo:(NSNumber *)from :(NSNumber *)to
{
    NSString *url = [NSString stringWithFormat:@"http://mathebumbler.com/rest/list_page?p=%d&n=%d",from.intValue,to.intValue];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFJSONRequestOperation *rq = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"%@",[JSON description]);
        NSArray *subject1 = [NSArray arrayWithArray:[JSON valueForKey:@"subject1"]];
        NSArray *subject2 = [NSArray arrayWithArray:[JSON valueForKey:@"subject2"]];
        NSArray *subject3 = [NSArray arrayWithArray:[JSON valueForKey:@"subject3"]];
        NSArray *subject4 = [NSArray arrayWithArray:[JSON valueForKey:@"subject4"]];
        NSArray *uid = [NSArray arrayWithArray:[JSON valueForKey:@"member_num"]];
        NSArray *qid = [NSArray arrayWithArray:[JSON valueForKey:@"num"]];

        NSArray *date = [NSArray arrayWithArray:[JSON valueForKey:@"buildtime"]];
        NSArray *votegreen = [NSArray arrayWithArray:[JSON valueForKey:@"vote_like"]];
        NSArray *voteblue = [NSArray arrayWithArray:[JSON valueForKey:@"vote_dislike"]];

        for (int i=0;i<subject1.count;i++) {
            
            Entity *e = [Entity insertInManagedObjectContext:self.managedObjectContext];
            [e setSubject1:[subject1 objectAtIndex:i]];
            [e setSubject2:[subject2 objectAtIndex:i]];
            [e setSubject3:[subject3 objectAtIndex:i]];
            [e setSubject4:[subject4 objectAtIndex:i]];
            [e setUid:[uid objectAtIndex:i]];
            [e setQid:[qid objectAtIndex:i]];
            e.qid = [qid objectAtIndex:i];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
            //NSDate *datecreate = [df dateFromString:[date objectAtIndex:i]];
            [e setDate:[df dateFromString:[date objectAtIndex:i]]];
            NSLog(@"%@",e.qid);
            NSString *vg = [votegreen objectAtIndex:i];
            [e setVotegreen:[NSNumber numberWithInt:vg.intValue]];
            NSString *vb = [voteblue objectAtIndex:i];
            [e setVoteblue:[NSNumber numberWithInt:vb.intValue]];
             
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //
    }];
    return rq;

}
-(AFJSONRequestOperation *)getFBNameMe
{
    FBSession *session;
    session = FBSession.activeSession;
    
    NSString *urlstring = [NSString stringWithFormat:@"https://graph.facebook.com/me?access_token=%@",session.accessToken];
    NSURL *url = [NSURL URLWithString:urlstring];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *rq = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //
    }];
    return rq;
}
@end
