//
//  BZNavigationController.m
//  Mathebumbler
//
//  Created by Boska on 12/12/17.
//  Copyright (c) 2012年 Boska. All rights reserved.
//

#import "BZNavigationController.h"

@interface BZNavigationController ()

@end

@implementation BZNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        //label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor yellowColor]; // change this color
        self.navigationItem.titleView = label;
        label.text = NSLocalizedString(@"PageThreeTitle", @"");
        [label sizeToFit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
