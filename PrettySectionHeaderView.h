//
//  PrettySectionHeaderView.h
//  TinyChatter
//
//  Created by jj on 12/5/4.
//  Copyright (c) 2012年 jtg2078@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrettySectionHeaderView : UIView

/** Specifies the gradient's start color.
 
 By default is a black tone. */
@property (nonatomic, retain) UIColor *gradientStartColor;

/** Specifies the gradient's end color.
 
 By default is a black tone. */
@property (nonatomic, retain) UIColor *gradientEndColor;

/** Specifies the top separator's color.
 
 By default is a black tone. */
@property (nonatomic, retain) UIColor *separatorLineColor;

@property (nonatomic, retain) NSString *headerTitle;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *textFont;

@end
