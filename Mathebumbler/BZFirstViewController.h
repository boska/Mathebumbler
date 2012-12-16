//
//  BZFirstViewController.h
//  Mathebumbler
//
//  Created by Boska on 12/11/30.
//  Copyright (c) 2012年 Boska. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BZFirstViewController : UIViewController <NSFetchedResultsControllerDelegate,UITextFieldDelegate>{
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}
@property (nonatomic, strong) NSMutableArray *qArray;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UITextField *inputField;
@property (nonatomic, strong) IBOutlet UIButton *sendButton;

@property (nonatomic ,strong) IBOutlet UILabel *ouputField;
@property (nonatomic ,strong) IBOutlet UILabel *progress;

@property (nonatomic ,strong) IBOutlet UIButton *fb_login_button;

@property (nonatomic) int count;
- (IBAction)authButtonAction:(id)sender;
- (IBAction)dissmissKeyboard:(id)sender;
- (IBAction)commit:(id)sender;

@end
