//
//  BJChatBaseBubbleCell.h
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/23.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJChatViewCellProtocol.h"
#import <IMMessage.h>
#import "IMMessage+ViewModel.h"

#define BJ_BUBBLE_ARROW_WIDTH 5 // bubbleView中，箭头的宽度
#define BJ_BUBBLE_VIEW_PADDING 10 // bubbleView 与 在其中的控件内边距
#define BJ_CELLPADDING 4 // Cell之间间距
#define BJ_NAME_LABEL_FONT_SIZE 14 // 字体

extern const float HEAD_SIZE;
extern const float HEAD_PADDING;

@interface BJChatBaseCell : UITableViewCell<BJChatViewCellProtocol>
@property (strong, nonatomic)IMMessage *message;
@property (strong, nonatomic)NSIndexPath *indexPath;

@property (nonatomic, strong) UIImageView *headImageView;       //头像
@property (nonatomic, strong) UILabel *nameLabel;               //姓名
@property (nonatomic, strong) UIView *bubbleContainerView;   //内容区域
@property (nonatomic, strong) UIImageView *backImageView; //背景图片

//sender
@property (nonatomic, strong) UIActivityIndicatorView *activity;
@property (nonatomic, strong) UIView *activityView;
@property (nonatomic, strong) UIButton *retryButton;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;


-(void)setCellInfo:(id)info indexPath:(NSIndexPath *)indexPath NS_REQUIRES_SUPER;
- (void)headViewPressed:(id)sender;
- (void)bubbleViewPressed:(id)sender;
- (void)bubbleViewLongPressed:(id)sender;

- (UIImage *)bubbleImage;
@end
