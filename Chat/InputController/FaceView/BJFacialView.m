//
//  MyFacialView.m
//  BJEducation
//
//  Created by archer on 11/28/14.
//  Copyright (c) 2014 com.bjhl. All rights reserved.
//

#import "BJFacialView.h"

#import "YLGIFImage.h"
#import "YLImageView.h"

@implementation BJFacialView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *emjList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emj" ofType:@"plist"]];
        NSMutableArray *faces = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *emojiTexts = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *emojiTitles = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSDictionary *oneDic in emjList) {
            [faces addObject:[YLGIFImage imageNamed:[oneDic objectForKey:@"GifName"]]];
             [emojiTexts addObject:[oneDic objectForKey:@"DisplayCode"]];
            [emojiTitles addObject:[oneDic objectForKey:@"DisplayCode"]];
        }
        _faces = [faces copy];
        _emojiTexts =  [emojiTexts copy];
        _emojiTitles = [emojiTitles copy];
        self.pagingEnabled = true;
        self.showsHorizontalScrollIndicator = false;
    }
    return self;
}


-(void)loadFacialView:(int)page size:(CGSize)size
{
    int maxRow = 2;
    int maxCol = 4;
    CGFloat itemWidth = self.frame.size.width / maxCol;
    CGFloat itemHeight = self.frame.size.height / maxRow;
    
    int pages = 0;
    pages = ceil([_faces count] * 1.0 / (maxRow * maxCol));
    self.contentSize = CGSizeMake(self.frame.size.width * pages, self.frame.size.height);
    
    /*
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setBackgroundColor:[UIColor clearColor]];
    [deleteButton setFrame:CGRectMake((maxCol - 1) * itemWidth, (maxRow - 1) * itemHeight, itemWidth, itemHeight)];
    [deleteButton setImage:[UIImage imageNamed:@"faceDelete"] forState:UIControlStateNormal];
    deleteButton.tag = 10000;
    [deleteButton addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteButton];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setFrame:CGRectMake((maxCol - 2) * itemWidth - 10, (maxRow - 1) * itemHeight + 5, itemWidth + 10, itemHeight - 10)];
    [sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setBackgroundColor:[UIColor colorWithRed:10 / 255.0 green:82 / 255.0 blue:104 / 255.0 alpha:1.0]];
    [self addSubview:sendButton];
    */
    for (int page = 0; page < pages; page++){
        for (int row = 0; row < maxRow; row++) {
            for (int col = 0; col < maxCol; col++) {
                int index = row * maxCol + col + page *(maxRow *maxCol);
                if (index < [_faces count]) {
                    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(page* self.frame.size.width + col * itemWidth, row * itemHeight, itemWidth, itemHeight)];
                    [view setBackgroundColor:[UIColor clearColor]];
                    YLImageView *imView = [[YLImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
                    [imView setImage:[_faces objectAtIndex:index]];
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemHeight-60)];
                    [titleLabel setText:[_emojiTitles objectAtIndex:index]];
                    [titleLabel setFont:[UIFont systemFontOfSize:14]];
                    [titleLabel setTextAlignment:NSTextAlignmentCenter];
                    
                    [view addSubview:imView];
                    [view addSubview:titleLabel];
                    
                    CGRect frame = imView.frame;
                    frame.origin = CGPointMake((itemWidth-60)/2, 0);
                    imView.frame = frame;
                    
                    frame = titleLabel.frame;
                    frame.origin.y = 60;
                    titleLabel.frame = frame;
                    
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selected:)];
                    [view addGestureRecognizer:tap];
                    view.tag = index;
                    
//                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//                    [button setBackgroundColor:[UIColor clearColor]];
//                    [button setFrame:CGRectMake(0, 0, itemWidth, itemHeight)];
//                    [view addSubview:button];
//                    
//                    button.tag = index;
//                    [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:view];
                }
                else{
                    break;
                }
            }
        }
    }
    
}

-(void)selected:(UIGestureRecognizer*)bt
{
    UIImage *f = [_faces objectAtIndex:bt.view.tag];
    if (_facialDelegate) {
        [_facialDelegate selectThenSendImage:f emoji:[_emojiTexts objectAtIndex:bt.view.tag]];
    }
}

+ (NSString *)imageNamedWithEmoji:(NSString *)emoji
{
    NSArray *emjList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emj" ofType:@"plist"]];
    NSString *imageName = nil;
    for (NSDictionary *dic in emjList) {
        NSString *disPlayName = [dic valueForKey:@"DisplayCode"];
        if([emoji rangeOfString:disPlayName].location !=NSNotFound)
        {
            imageName = [dic valueForKey:@"GifName"];
        }
    }
    return imageName;
}

+ (NSString *)imageUrlWithEmoji:(NSString *)emoji;
{
    NSArray *emjList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emj" ofType:@"plist"]];
    NSString *imageName = nil;
    for (NSDictionary *dic in emjList) {
        NSString *disPlayName = [dic valueForKey:@"DisplayCode"];
        if([emoji rangeOfString:disPlayName].location !=NSNotFound)
        {
            imageName = [dic valueForKey:@"PngUrl"];
        }
    }
    return imageName;
}

@end
