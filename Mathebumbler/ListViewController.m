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
#import "BlockActionSheet.h"
#define QsPerPage 10
@interface ListViewController ()

@end

@implementation ListViewController
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize fetchObjects;
@synthesize myTableView;
@synthesize currentPage;
@synthesize endPage;
@synthesize loadingState;
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
    currentPage = 0;
    endPage = QsPerPage;
    [super viewDidLoad];
     BZAppDelegate *appDelegate = (BZAppDelegate *)[[UIApplication sharedApplication] delegate];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    managedObjectContext = appDelegate.managedObjectContext;
    
    // 
    
    AFJSONRequestOperation *rq =  [appDelegate loadQuotesFromTo:[NSNumber numberWithInt:currentPage]:[NSNumber numberWithInt:QsPerPage] ];
   [rq setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
       NSArray *subject1 = [NSArray arrayWithArray:[responseObject valueForKey:@"subject1"]];
       NSArray *subject2 = [NSArray arrayWithArray:[responseObject valueForKey:@"subject2"]];
       NSArray *subject3 = [NSArray arrayWithArray:[responseObject valueForKey:@"subject3"]];
       NSArray *subject4 = [NSArray arrayWithArray:[responseObject valueForKey:@"subject4"]];
       NSArray *uid = [NSArray arrayWithArray:[responseObject valueForKey:@"member_num"]];
       NSArray *qid = [NSArray arrayWithArray:[responseObject valueForKey:@"num"]];
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
           [e setQid:[qid objectAtIndex:i]];
           NSDateFormatter *df = [[NSDateFormatter alloc] init];
           [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
           //NSDate *datecreate = [df dateFromString:[date objectAtIndex:i]];
           [e setDate:[df dateFromString:[date objectAtIndex:i]]];
           //[e setDate:[date objectAtIndex:i]];
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

               [myTableView reloadData];
           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
               //
           }];
           [rq start];
           
           NSString *fb_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"fb_id"];
           
           NSURL *urlvote = [NSURL URLWithString:[NSString stringWithFormat:@"http://mathebumbler.com/rest/list_single?n=%@&fbid=%@",e.qid,fb_id]];
           NSURLRequest *requestvote = [NSURLRequest requestWithURL:urlvote];

           AFJSONRequestOperation *getVotekind = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestvote success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                //
               NSString *votekind = [[JSON valueForKey:@"vote_kind"] lastObject];
               if ([[JSON valueForKey:@"vote_kind"] lastObject] != [NSNull null]) {
                   
                   
                   if ([votekind isEqualToString:@"blue"]) {
                       // NSLog(@"%@,%@",qid,[[JSON valueForKey:@"vote_kind"] lastObject]);
                       e.votekind = @"blue";
                   } else if ([votekind isEqualToString:@"green"])
                   {
                       e.votekind = @"green";
                    
                   }
               }
                else {
                   e.votekind = @"none";
                }
           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
               //
           }];
           [getVotekind start];
       }
       NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
       NSEntityDescription *entity = [NSEntityDescription
                                      entityForName:@"Entity" inManagedObjectContext:managedObjectContext];
       [fetchRequest setEntity:entity];
       NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
       [fetchRequest setSortDescriptors:[NSArray arrayWithObjects: sort1, nil]];

       
       
       self.fetchedResultsController.delegate =self;
       NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                    managedObjectContext:managedObjectContext
                                                                                      sectionNameKeyPath:@"date"
                                                                                               cacheName:nil];
       self.fetchedResultsController = controller;
       [self.fetchedResultsController performFetch:nil];
       [self.myTableView reloadData];
       NSLog(@"%d secs",self.fetchedResultsController.sections.count);
       
       //fetchObjects = [NSMutableArray arrayWithArray:[managedObjectContext executeFetchRequest:fetchRequest error:nil]];
       
       
       // Uncomment the following line to preserve selection between presentations.
       // self.clearsSelectionOnViewWillAppear = NO;
       
       // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
       // self.navigationItem.rightBarButtonItem = self.editButtonItem;
       //NSLog(@"%d",fetchObjects.count);

   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       //
   }];
    [rq start];
    
    //fetch qs
    //
    //[self updateVoteStatus:@"123"];
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
    return self.fetchedResultsController.sections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.fetchedResultsController.sections;
	
	if (section < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSLog(@"%d,%d",indexPath.row,indexPath.section);
    static NSString *CellIdentifier = @"MTBTableViewCell";
    MTBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MTBTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    //Entity *e = [fetchObjects objectAtIndex:indexPath.row];
    Entity *e = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"%@",e.votekind);
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
    cell.tag = e.qid.intValue;
    cell.name.text = e.name;
    cell.date.text = [formatter stringFromDate:e.date];
    cell.quotes.text = [NSString stringWithFormat:@"%@,%@,%@,%@。",e.subject1,e.subject2,e.subject3,e.subject4];
    [cell.blue setBackgroundImage:[UIImage imageNamed:@"blue"] forState:UIControlStateNormal];
    //cell.blue.titleLabel.text = [NSString stringWithFormat:@"%d",e.voteblue.intValue];
    cell.blueconut.text =  [NSString stringWithFormat:@"%d",e.voteblue.intValue];
    [cell.green setBackgroundImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
    //cell.green.titleLabel.text = [NSString stringWithFormat:@"%d",e.votegreen.intValue];
    cell.greencount.text =  [NSString stringWithFormat:@"%d",e.votegreen.intValue];

    [cell.blue setBackgroundColor:[UIColor clearColor]];
    [cell.green setBackgroundColor:[UIColor clearColor]];

    if ([e.votekind isEqualToString:@"blue"]) {
        [cell.blue setBackgroundImage:[UIImage imageNamed:@"blue_"] forState:UIControlStateNormal];;
    } else if ([e.votekind isEqualToString:@"green"])
    {
        [cell.green setBackgroundImage:[UIImage imageNamed:@"green_"] forState:UIControlStateNormal];;
    }
    UITapGestureRecognizer *greenTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voteGreen:)];
    UITapGestureRecognizer *blueTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voteBlue:)];

    //UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTabCell:)];
    greenTap.delegate = self;
    blueTap.delegate = self;
    
    [cell.blue addGestureRecognizer:blueTap];
    [cell.green addGestureRecognizer:greenTap];
    //NSLog(@"%@",e.qid);
    // Configure the cell...
    //[self updateVoteStatus:e.qid andIndexPath:indexPath];

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
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSArray *sections = self.fetchedResultsController.sections;
	
    //NSUInteger row = [sections count];
    //NSUInteger count = [self.messageFRC.sections count];
    
	if (section < [sections count])
	{
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
		if(sectionInfo.numberOfObjects == 0)
            return nil;
        
        Entity *e = [sectionInfo.objects objectAtIndex:0];

         UIView *sectionView = [[UIView alloc] init];
        sectionView.frame = CGRectMake(0, 0, 320   ,27);
        sectionView.backgroundColor = [UIColor lightGrayColor];
        
        
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.frame = sectionView.frame ;
        dateLabel.font = [UIFont boldSystemFontOfSize:10];
        //dateLabel.textAlignment = UITextAlignmentCenter;
        dateLabel.textColor = [UIColor darkGrayColor];
        dateLabel.backgroundColor = [UIColor clearColor];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        //Optionally for time zone converstions
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Taipei"]];

        dateLabel.text = [formatter stringFromDate:e.date];
        dateLabel.text = [NSString stringWithFormat:@"%@(%d)",[formatter stringFromDate:e.date],sectionInfo.numberOfObjects];
        [sectionView addSubview:dateLabel];
        //[dateLabel release];
        
        return sectionView;
	}
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 27;
}

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
    BlockActionSheet *sheet = [[BlockActionSheet alloc]initWithTitle:@""];
    [sheet addButtonWithTitle:@"Comment" handler:^{
        
    }];
    sheet.destructiveButtonIndex = [sheet addButtonWithTitle:@"cancel" handler:nil];
    BZAppDelegate *appDelegte = (BZAppDelegate *)[[UIApplication sharedApplication] delegate];
    [sheet showInView:appDelegte.window.rootViewController.view];
    NSLog(@"%@",cell.quotes.text);
}
- (void)updateVoteStatus:(NSString *)qid andIndexPath:(NSIndexPath*)indexpath
{

}
- (void)voteGreen:(id)sender
{   
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    NSIndexPath *path =  [self.myTableView indexPathForRowAtPoint:[gesture locationInView:self.myTableView]];
    //MTBTableViewCell *cell = (MTBTableViewCell*)[self.myTableView cellForRowAtIndexPath:path];
    Entity *e = [self.fetchedResultsController objectAtIndexPath:path];
    NSString *fb_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"fb_id"];

    if ([e.votekind isEqualToString:@"green"]) {
        e.votekind = @"none";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://mathebumbler.com/vote_api.php?type=dis&n=%@&fbid=%@&kind=green",e.qid,fb_id]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *rq = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        [rq setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"suc dis green");
            int value = [e.votegreen intValue];
            e.votegreen = [NSNumber numberWithInt:value - 1];
            [self.myTableView reloadData];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"fail dis green ");
        }];
        [rq start];
    } else {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://mathebumbler.com/vote_api.php?type=add&n=%@&fbid=%@&kind=green",e.qid,fb_id]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *rq = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        [rq setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"suc add green");
            int value = [e.votegreen intValue];
            e.votegreen = [NSNumber numberWithInt:value + 1];
            [self.myTableView reloadData];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"fail add green ");
        }];
        [rq start];

        e.votekind = @"green";
    }
      NSLog(@"%@",e.votekind);
    [self.myTableView reloadData];
}

- (void)voteBlue:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    NSIndexPath *path =  [self.myTableView indexPathForRowAtPoint:[gesture locationInView:self.myTableView]];
    //MTBTableViewCell *cell = (MTBTableViewCell*)[self.myTableView cellForRowAtIndexPath:path];
    Entity *e = [self.fetchedResultsController objectAtIndexPath:path];
    NSString *fb_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"fb_id"];

    if ([e.votekind isEqualToString:@"blue"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://mathebumbler.com/vote_api.php?type=dis&n=%@&fbid=%@&kind=blue",e.qid,fb_id]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *rq = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        [rq setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"suc dis blue");
            int value = [e.voteblue intValue];
            e.voteblue = [NSNumber numberWithInt:value - 1];
            [self.myTableView reloadData];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"fail dis blue");
            
        }];
        [rq start];

        e.votekind = @"none";
        
    } else {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://mathebumbler.com/vote_api.php?type=add&n=%@&fbid=%@&kind=blue",e.qid,fb_id]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *rq = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        [rq setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"suc add blue");
            int value = [e.voteblue intValue];
            e.voteblue = [NSNumber numberWithInt:value + 1];
            [self.myTableView reloadData];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"fail add blue");

        }];
        [rq start];
        e.votekind = @"blue";
    }
    NSLog(@"%@",e.votekind);
    [self.myTableView reloadData];

}
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    
    [self.myTableView beginUpdates];
    NSLog(@"a");
    //delayOffset = self.myTableView.contentOffset;
    [UIView setAnimationsEnabled:NO];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.myTableView endUpdates];
    NSLog(@"a");

    [UIView setAnimationsEnabled:YES];
    
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    //UITableView *tableView = self.myTableView;
    NSLog(@"a");
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
                    
            break;
            
        case NSFetchedResultsChangeDelete:
                     break;
            
        case NSFetchedResultsChangeUpdate:
                       
            break;
            
        case NSFetchedResultsChangeMove:
                   break;
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    
    float reload_distance = 50;
    if(y > h + reload_distance) {
        NSLog(@"load more rows");
       
        
        if (!loadingState) {
            loadingState = YES;
            NSLog(@"load more rows");
            [self loadMore];
        }
        // loading........
        
        
    }
}
-(void)loadMore
{
    currentPage+=1;
    BZAppDelegate *appDelegate = (BZAppDelegate *)[[UIApplication sharedApplication] delegate];

    AFJSONRequestOperation *rq =  [appDelegate loadQuotesFromTo:[NSNumber numberWithInt:currentPage*QsPerPage]:[NSNumber numberWithInt:currentPage*QsPerPage+QsPerPage] ];
    [rq setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *subject1 = [NSArray arrayWithArray:[responseObject valueForKey:@"subject1"]];
        NSArray *subject2 = [NSArray arrayWithArray:[responseObject valueForKey:@"subject2"]];
        NSArray *subject3 = [NSArray arrayWithArray:[responseObject valueForKey:@"subject3"]];
        NSArray *subject4 = [NSArray arrayWithArray:[responseObject valueForKey:@"subject4"]];
        NSArray *uid = [NSArray arrayWithArray:[responseObject valueForKey:@"member_num"]];
        NSArray *qid = [NSArray arrayWithArray:[responseObject valueForKey:@"num"]];
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
            [e setQid:[qid objectAtIndex:i]];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            //NSDate *datecreate = [df dateFromString:[date objectAtIndex:i]];
            [e setDate:[df dateFromString:[date objectAtIndex:i]]];
            //[e setDate:[date objectAtIndex:i]];
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
                
                [myTableView reloadData];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                //
            }];
            [rq start];
            
            NSString *fb_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"fb_id"];
            
            NSURL *urlvote = [NSURL URLWithString:[NSString stringWithFormat:@"http://mathebumbler.com/rest/list_single?n=%@&fbid=%@",e.qid,fb_id]];
            NSURLRequest *requestvote = [NSURLRequest requestWithURL:urlvote];
            
            AFJSONRequestOperation *getVotekind = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestvote success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                //
                NSString *votekind = [[JSON valueForKey:@"vote_kind"] lastObject];
                if ([[JSON valueForKey:@"vote_kind"] lastObject] != [NSNull null]) {
                    
                    
                    if ([votekind isEqualToString:@"blue"]) {
                        // NSLog(@"%@,%@",qid,[[JSON valueForKey:@"vote_kind"] lastObject]);
                        e.votekind = @"blue";
                    } else if ([votekind isEqualToString:@"green"])
                    {
                        e.votekind = @"green";
                        
                    }
                }
                else {
                    e.votekind = @"none";
                }
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                //
            }];
            [getVotekind start];
        }
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Entity" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects: sort1, nil]];
        
        
        
        self.fetchedResultsController.delegate =self;
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                     managedObjectContext:managedObjectContext
                                                                                       sectionNameKeyPath:@"date"
                                                                                                cacheName:nil];
        self.fetchedResultsController = controller;
        [self.fetchedResultsController performFetch:nil];
        [self.myTableView reloadData];
        NSLog(@"%d secs",self.fetchedResultsController.sections.count);
        loadingState = NO;

        //fetchObjects = [NSMutableArray arrayWithArray:[managedObjectContext executeFetchRequest:fetchRequest error:nil]];
        
        
        // Uncomment the following line to preserve selection between presentations.
        // self.clearsSelectionOnViewWillAppear = NO;
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem;
        //NSLog(@"%d",fetchObjects.count);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
    [rq start];
    

}
@end
