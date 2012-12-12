//
//  PrettySectionHeaderView.m
//  TinyChatter
//
//  Created by jj on 12/5/4.
//  Copyright (c) 2012年 jtg2078@hotmail.com. All rights reserved.
//

#import "PrettySectionHeaderView.h"
#import "PrettyDrawing.h"

@implementation PrettySectionHeaderView

#pragma mark - define

#define DEFAULT_BG_COLOR_GRADIENT_START     [UIColor colorWithHex:0xCFCFCF]
#define DEFAULT_BG_COLOR_GRADIENT_END       [UIColor colorWithHex:0xCFCFCF]
#define DEFAULT_SEPARATOR_LINE_COLOR        [UIColor colorWithHex:0xb7b7b7]
#define DEFAULT_TEXT_COLOR                  [UIColor whiteColor]
#define DEFAULT_TEXT_FONT                   [UIFont boldSystemFontOfSize:12]

#pragma mark - synthesize

@synthesize gradientStartColor;
@synthesize gradientEndColor;
@synthesize separatorLineColor;
@synthesize headerTitle;
@synthesize textColor;
@synthesize textFont;

#pragma mark - dealloc

- (void) dealloc {
    [gradientStartColor release];
    [gradientEndColor release];
    [separatorLineColor release];
    [headerTitle release];
    [textColor release];
    [textFont release];
    
    [super dealloc];
}

#pragma mark - init

- (void) initializeVars 
{
    self.contentMode = UIViewContentModeRedraw;
    
    self.gradientStartColor = DEFAULT_BG_COLOR_GRADIENT_START;
    self.gradientEndColor = DEFAULT_BG_COLOR_GRADIENT_END;
    self.separatorLineColor = DEFAULT_SEPARATOR_LINE_COLOR;
    
    self.textColor = DEFAULT_TEXT_COLOR;
    self.textFont = DEFAULT_TEXT_FONT;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeVars];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeVars];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initializeVars];
    }
    return self;
}

- (void)drawText
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSaveGState(ctx);
    
    CGContextSetFillColorWithColor(ctx, self.textColor.CGColor);
    
    CGPoint textPosition = CGPointMake(5, 5);
    [self.headerTitle drawAtPoint:textPosition withFont:self.textFont];
    
    CGContextRestoreGState(ctx);
}

- (void)drawRect:(CGRect)rect 
{
    [super drawRect:rect];
    
    [PrettyDrawing drawGradient:rect fromColor:self.gradientStartColor toColor:self.gradientEndColor];
    [PrettyDrawing drawLineAtHeight:0 rect:rect color:self.separatorLineColor width:0.5];
    [PrettyDrawing drawLineAtHeight:rect.size.height-0.5 rect:rect color:self.separatorLineColor width:0.5];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShadow(ctx, CGSizeMake(1, 1), 3);
    [self drawText];
    
   
}

@end
