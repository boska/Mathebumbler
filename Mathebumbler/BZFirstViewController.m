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
#import "BlockAlertView.h"
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface BZFirstViewController ()

@end

@implementation BZFirstViewController
@synthesize managedObjectContext;
@synthesize inputField,ouputField,qArray;
@synthesize fetchedResultsController;
@synthesize count,sendButton,fb_login_button,progress;
- (void)viewDidLoad
{
    BZAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    self.tabBarItem.image = [UIImage imageNamed:@"plus"];
    //check if fb logon
    NSString *fb_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"fb_id"];
    if (fb_id) {
        self.fb_login_button.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"fb_login_"]];
        [self.fb_login_button setUserInteractionEnabled:NO];
        //self.fb_login_button.titleLabel.frame = CGRectMake(0, 0, 100, 25);
        [self.fb_login_button setTitle:[[NSUserDefaults standardUserDefaults] valueForKey:@"fb_name"] forState:UIControlStateNormal];

    } else
         self.fb_login_button.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"fb_login"]];
    
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(slideDown:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeGestureRecognizer];

    count = 0;
    sendButton.hidden = YES;
    [super viewDidLoad];
    qArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",nil];
    inputField.delegate = self;
        [self.view setBackgroundColor:UIColorFromRGB(0x7ACEFF)];
    

}
- (IBAction)authButtonAction:(id)sender{
    BZAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    // The user has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    [appDelegate openSessionWithAllowLoginUI:YES view:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 4) ? NO : YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    sendButton.hidden = YES;

    count+=1;
    NSLog(@"%d",count);
    switch (count) {
        case 1:
            //dd
            [self.progress setText:@"1/4"];
            [self.ouputField setText:[NSString stringWithString:inputField.text]];
            [qArray replaceObjectAtIndex:0 withObject:[inputField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            inputField.text = @"";
            NSLog(@"%@",ouputField.text);
            [inputField becomeFirstResponder];
            break;
        case 2:
            [self.progress setText:@"2/4"];

            [self.ouputField setText:[NSString stringWithFormat:@"%@,%@",self.ouputField.text,inputField.text]];
            [qArray replaceObjectAtIndex:1 withObject:[inputField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

            inputField.text = @"";
            [inputField becomeFirstResponder];

            //
            break;
        case 3:
            //
            [self.progress setText:@"3/4"];

            [self.ouputField setText:[NSString stringWithFormat:@"%@,%@",self.ouputField.text,inputField.text]];
            [qArray replaceObjectAtIndex:2 withObject:[inputField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

            inputField.text = @"";
            [inputField becomeFirstResponder];


            break;
        case 4:{
            [self.progress setText:@"4/4"];

            [self.ouputField setText:[NSString stringWithFormat:@"%@,%@。",self.ouputField.text,inputField.text]];
            [qArray replaceObjectAtIndex:3 withObject:[inputField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

            [inputField resignFirstResponder];
            inputField.text = @"";
            sendButton.hidden = NO;
            //
            count = 0;
            break;
            }
        default:
            
            break;
    }
    //NSLog(@"%@",qArray.description);
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
       [textField resignFirstResponder];
    //[self textFieldDidEndEditing:textField];
    return  YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //NSLog(@"tses");
    if (textField.text.length == 4) {
        //textField.text = @"";
        return YES;
    }
    [self earthquake:textField];
    return NO;
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
- (IBAction)commit:(id)sender
{
    //NSString *qua = [NSString stringWithFormat:@"%@,%@,%@,%@",[qArray objectAtIndex:0],[qArray objectAtIndex:1],[qArray objectAtIndex:2],[qArray objectAtIndex:3]];
    BlockAlertView *alertCheck = [[BlockAlertView alloc]initWithTitle:self.ouputField.text message:@"確定送出?"];
    [alertCheck addButtonWithTitle:@"YES" handler:^{
        
            NSString *fb_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"fb_id"];

            NSString *urlstring = [NSString stringWithFormat:@"http://mathebumbler.com/rest/insert?s1=%@&s2=%@&s3=%@&s4=%@&fbid=%@",
                                   [qArray objectAtIndex:0],
                                   [qArray objectAtIndex:1],
                                   [qArray objectAtIndex:2],
                                   [qArray objectAtIndex:3],
                                   fb_id
                                   ];
            NSLog(@"%@",urlstring);
            NSURL *url = [NSURL URLWithString:urlstring];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            BlockAlertView *alert =[[BlockAlertView alloc]initWithTitle:@"thank you !" message:@""];
            alert.cancelButtonIndex = [alert addButtonWithTitle:@"OK" handler:^{
                //[readerView start];
            }];
            AFJSONRequestOperation *rq = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             
                sendButton.hidden = YES;
                [alert show];

            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                //
            }];
            
            [rq start];
    }];
    alertCheck.cancelButtonIndex = [alertCheck addButtonWithTitle:@"NO" handler:nil];
    [alertCheck show];
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
- (void)earthquake:(UIView*)itemView
{
    CGFloat t = 2.0;
    
    CGAffineTransform leftQuake  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0);
    CGAffineTransform rightQuake = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0);
    
    itemView.transform = leftQuake;  // starting point
    
    [UIView beginAnimations:@"earthquake" context:(__bridge void *)(itemView)];
    [UIView setAnimationRepeatAutoreverses:YES]; // important
    [UIView setAnimationRepeatCount:5];
    [UIView setAnimationDuration:0.07];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    itemView.transform = rightQuake; // end here & auto-reverse
    
    [UIView commitAnimations];
}

- (void)earthquakeEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([finished boolValue])
    {
    	UIView* item = (__bridge UIView *)context;
    	item.transform = CGAffineTransformIdentity;
    }
}
- (void)slideDown:(id)sender
{
    [self.inputField resignFirstResponder];
}
@end
