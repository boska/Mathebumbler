//
//  ListViewController.m
//  Mathebumbler
//
//  Created by Boska on 12/12/10.
//  Copyright (c) 2012年 Boska. All rights reserved.
//
#import "BZAppDelegate.h"
#import "ListViewController.h"
#import "Entity.h"
#import "MTBTableViewCell.h"
#import "AFJSONRequestOperation.h"
#import "AFImageRequestOperation.h"
#import "UIImageView+AFNetworking.h"
@interface ListViewController ()

@end

@implementation ListViewController
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize fetchObjects;
@synthesize myTableView;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     BZAppDelegate *appDelegate = (BZAppDelegate *)[[UIApplication sharedApplication] delegate];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    managedObjectContext = appDelegate.managedObjectContext;
       AFJSONRequestOperation *rq =  [appDelegate loadQuotesFromTo:[NSNumber numberWithInt:0]:[NSNumber numberWithInt:20] ];
   [rq setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
       NSArray *subject1 = [NSArray arrayWithArray:[responseObject valueForKey:@"subject1"]];
       NSArray *subject2 = [NSArray arrayWithArray:[responseObject valueForKey:@"subject2"]];
       NSArray *subject3 = [NSArray arrayWithArray:[responseObject valueForKey:@"subject3"]];
       NSArray *subject4 = [NSArray arrayWithArray:[responseObject valueForKey:@"subject4"]];
       NSArray *uid = [NSArray arrayWithArray:[responseObject valueForKey:@"member_num"]];
       NSArray *date = [NSArray arrayWithArray:[responseObject valueForKey:@"buildtime"]];
       NSArray *votegreen = [NSArray arrayWithArray:[responseObject valueForKey:@"vote_like"]];
       NSArray *voteblue = [NSArray arrayWithArray:[responseObject valueForKey:@"vote_dislike"]];
       
       for (int i=0;i<subject1.count;i++) {
           
           Entity *e = [Entity insertInManagedObjectContext:self.managedObjectContext];
           [e setSubject1:[subject1 objectAtIndex:i]];
           [e setSubject2:[subject2 objectAtIndex:i]];
           [e setSubject3:[subject3 objectAtIndex:i]];
           [e setSubject4:[subject4 objectAtIndex:i]];
           [e setUid:[uid objectAtIndex:i]];
           NSDateFormatter *df = [[NSDateFormatter alloc] init];
           [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
           //NSDate *datecreate = [df dateFromString:[date objectAtIndex:i]];
           [e setDate:[df dateFromString:[date objectAtIndex:i]]];
           NSLog(@"%@",e.date.description);
           NSString *vg = [votegreen objectAtIndex:i];
           [e setVotegreen:[NSNumber numberWithInt:vg.intValue]];
           NSString *vb = [voteblue objectAtIndex:i];
           [e setVoteblue:[NSNumber numberWithInt:vb.intValue]];
           
           //get name from fb api
           NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@",[uid objectAtIndex:i]]];
           NSURLRequest *request = [NSURLRequest requestWithURL:url];
           AFJSONRequestOperation *rq = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
               NSString *user_name = [JSON valueForKey:@"name"];
               e.name = user_name;
           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
               //
           }];
           [rq start];
       }
       NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
       NSEntityDescription *entity = [NSEntityDescription
                                      entityForName:@"Entity" inManagedObjectContext:managedObjectContext];
       [fetchRequest setEntity:entity];
       fetchObjects = [NSMutableArray arrayWithArray:[managedObjectContext executeFetchRequest:fetchRequest error:nil]];
       
       
       // Uncomment the following line to preserve selection between presentations.
       // self.clearsSelectionOnViewWillAppear = NO;
       
       // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
       // self.navigationItem.rightBarButtonItem = self.editButtonItem;
       NSLog(@"%d",fetchObjects.count);
       [myTableView reloadData];

   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       //
   }];
    [rq start];
    
    //fetch qs
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    return fetchObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSLog(@"1");
    static NSString *CellIdentifier = @"MTBTableViewCell";
    MTBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MTBTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    Entity *e = [fetchObjects objectAtIndex:indexPath.row];
    //NSLog(@"%@",e.uid);
    //NSLog(@"%@,%@,%@,%@。",e.subject1,e.subject2,e.subject3,e.subject4);
    //convert date to string
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    //Optionally for time zone converstions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Taipei"]];
    

    //NSLog(@"%@",e.date.description);
    NSString *urlstring = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",e.uid];
    NSURL *url = [NSURL URLWithString:urlstring];

   
    [cell.thumbnail setImageWithURL:url placeholderImage:nil];
    cell.date.text = [formatter stringFromDate:e.date];
    cell.quotes.text = [NSString stringWithFormat:@"%@,%@,%@,%@。",e.subject1,e.subject2,e.subject3,e.subject4];
    // Configure the cell...
   
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    MTBTableViewCell *cell = (MTBTableViewCell *)[self tableView:myTableView cellForRowAtIndexPath:indexPath];
    
    NSLog(@"%@",cell.quotes.text);
}

@end
