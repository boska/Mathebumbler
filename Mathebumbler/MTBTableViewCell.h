//
//  MTBTableViewCell.h
//  Mathebumbler
//
//  Created by mmobile01 chiang on 12/12/11.
//  Copyright (c) 2012年 Boska. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTBTableViewCell : UITableViewCell
@property (strong,nonatomic) IBOutlet UIImageView *thumbnail;
@property (strong,nonatomic) IBOutlet UILabel *quotes;
@property (strong,nonatomic) IBOutlet UILabel *name;
@property (strong,nonatomic) IBOutlet UILabel *date;


@end
