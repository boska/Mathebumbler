//
//  BZAppDelegate.h
//  Mathebumbler
//
//  Created by Boska on 12/11/30.
//  Copyright (c) 2012年 Boska. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AFJSONRequestOperation.h"
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface BZAppDelegate : UIResponder <UIApplicationDelegate>{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

}
extern NSString *const FBSessionStateChangedNotification;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)getFBid;
- (AFJSONRequestOperation *)loadQuotesFromTo:(NSNumber *)from:(NSNumber *)to;
@end
