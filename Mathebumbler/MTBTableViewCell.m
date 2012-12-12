//
//  MTBTableViewCell.m
//  Mathebumbler
//
//  Created by mmobile01 chiang on 12/12/11.
//  Copyright (c) 2012年 Boska. All rights reserved.
//

#import "MTBTableViewCell.h"

@implementation MTBTableViewCell
@synthesize name;
@synthesize quotes;
@synthesize date;
@synthesize thumbnail;
@synthesize blue;
@synthesize green;
@synthesize blueconut;
@synthesize greencount;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
