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
#import "PrettySectionHeaderView.h"

#define QsPerPage 10
#define BACKGROUND [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
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
    myTableView.backgroundColor = BACKGROUND;
    managedObjectContext = appDelegate.managedObjectContext;
    //
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl setTintColor:UIColorFromRGB(0x66C1FF)];
    [self.refreshControl setBackgroundColor:BACKGROUND];
    //    self.refreshControl.tintColor = [UIColor blueColor];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"PullToRefresh"];
    [self.refreshControl addTarget:self action:@selector(pulldown:) forControlEvents:UIControlEventValueChanged];
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
           //NSLog(@"%@",e.date.description);
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
    
    //fetch qs
    //
    //[self updateVoteStatus:@"123"];
    loadingState = YES;

    [rq start];
    //loadingState = YES;
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
     //NSLog(@"%d,%d",indexPath.row,indexPath.section);
    static NSString *CellIdentifier = @"MTBTableViewCell";
    MTBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background" ]];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MTBTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    //Entity *e = [fetchObjects objectAtIndex:indexPath.row];
    Entity *e = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //NSLog(@"%@",e.votekind);
    //NSLog(@"%@,%@,%@,%@。",e.subject1,e.subject2,e.subject3,e.subject4);
    //convert date to string
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    //Optionally for time zone converstions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Taipei"]];
    

    //NSLog(@"%@",e.date.description);
    NSString *urlstring = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",e.uid];
    NSURL *url = [NSURL URLWithString:urlstring];

    //cell.thumbnail = [[UIImageView alloc]init];
    
    [cell.thumbnail setImageWithURL:url placeholderImage:[UIImage imageNamed:@"background"]];
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

        PrettySectionHeaderView *sectionView = [[PrettySectionHeaderView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
        sectionView.gradientStartColor = UIColorFromRGB(0x66C1FF);
        sectionView.gradientEndColor = UIColorFromRGB(0x0066FF);
        // UIView *sectionView = [[UIView alloc] init];
        //sectionView.frame = CGRectMake(0, 0, 320   ,20);
        //sectionView.backgroundColor = UIColorFromRGB(0x66C1FF);
        
        
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.frame = sectionView.frame ;
        dateLabel.font = [UIFont boldSystemFontOfSize:10];
        //dateLabel.textAlignment = UITextAlignmentCenter;
        dateLabel.textColor = [UIColor whiteColor];
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
    return 20;
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
    [sheet addButtonWithTitle:@"Copy" handler:^{
        [UIPasteboard generalPasteboard].string = cell.quotes.text;
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
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    
    if (maximumOffset - currentOffset <= -40) {
        
        NSLog(@"reload");
        [self loadMore];
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
        NSLog(@"%d secs,%d",self.fetchedResultsController.sections.count,self.fetchedResultsController.fetchedObjects.count);
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
-(void)pulldown:(id)sender
{
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(refresh:) userInfo:nil repeats:NO];

}
-(void)refresh:(id)sender
{
    BZAppDelegate *appDelegate = (BZAppDelegate *)[[UIApplication sharedApplication] delegate];
    currentPage = 0;
    endPage = QsPerPage;
    NSLog(@"refresh");
    fetchedResultsController.delegate = nil;               // turn off delegate callbacks
    for (Entity *e in [fetchedResultsController fetchedObjects]) {
        [managedObjectContext deleteObject:e];
    }
    [self.managedObjectContext save:nil];
    //NSError *error;
    //if (![fetchedResultsController performFetch:&error]) { // resync controller
        // TODO: Handle the error appropriately.
    //    NSLog(@"fetchMessages error %@, %@", error, [error userInfo]);
    //}
    
    //   fetchedResultsController.delegate = self;
    [myTableView reloadData];
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
            //NSLog(@"%@",e.date.description);
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
        [self.refreshControl endRefreshing];
        [self.myTableView reloadData];
        NSLog(@"%d secs %d",self.fetchedResultsController.sections.count,self.fetchedResultsController.fetchedObjects.count);
        
            
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [rq start];

    //[self.refreshControl endRefreshing];
    // reconnect after mass delete
 }
@end
