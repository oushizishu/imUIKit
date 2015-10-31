//
//  BJTipTextTableViewCell.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/29.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJGossipTableViewCell.h"
#import "BJChatCellFactory.h"
#import "BJChatBaseCell.h"
#import <BJHL-Common-iOS-SDK/UIColor+Util.h>
#import "MyXmlDomParser.h"

const float Gossip_Content_Label_Max_Width = 200;
const float Gossip_Content_Label_Height = 18;

@interface CustomLable()

@end

@implementation CustomLable

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.font = [UIFont systemFontOfSize:BJ_GOSSIP_FONTSIZE];
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor colorWithHexString:BJ_GOSSIP_FONTCOLOR];
        self.numberOfLines = 1;
        self.clipsToBounds = YES;
    }
    
    return self;
}

-(void)addHrefLink:(NSString*)href
{
    self.href = href;
    self.textColor = [UIColor bj_blue_200];
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *hitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lablePressed:)];
    [self addGestureRecognizer:hitTap];
}

-(void)lablePressed:(id)aciton
{
    if (self.deleagate != nil) {
        [self.deleagate userHitHrefLink:self];
    }
}

@end

@interface BJGossipTableViewCell ()
@property (strong ,nonatomic) UIView *gossipView;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong ,nonatomic) NSMutableArray *lableArray;
@end

@implementation BJGossipTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (void)load
{
    [[BJChatCellFactory sharedInstance] registerClass:[self class] forMessageType:eMessageType_CMD];
    [[BJChatCellFactory sharedInstance] registerClass:[self class] forMessageType:eMessageType_NOTIFICATION];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - Protocol
/**
 *  实现初始化方法，外部只调用此方法
 *
 *  @return
 */
- (instancetype)init;
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BJGossipTableViewCell class])];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
-(void)setCellInfo:(id)info indexPath:(NSIndexPath *)indexPath;
{
    
    CGFloat screenW = [[UIScreen mainScreen] bounds].size.width;
    self.contentView.frame = CGRectMake(0, 0, screenW, self.frame.size.height);
    
    if (self.contentLabel != nil) {
        [self.contentLabel removeFromSuperview];
    }
    if (self.lableArray != nil) {
        for (int i = 0; i < [self.lableArray count]; i++) {
            UILabel *itemLable = [self.lableArray objectAtIndex:i];
            [itemLable removeFromSuperview];
        }
        [self.lableArray removeAllObjects];
    }
    if (self.lableArray == nil) {
        self.lableArray = [[NSMutableArray alloc] init];
    }
    
    self.message = info;
    self.indexPath = indexPath;
    IMNotificationMessageBody *body = self.message.getNotificationBody;
    NSString *showMsg = body.content;
    
    UIFont *font = [UIFont systemFontOfSize:BJ_GOSSIP_FONTSIZE];
    
    MyXmlDomParser *parser = [[MyXmlDomParser alloc] init];
    if (body.type == eTxtMessageContentType_RICH_TXT && [parser parserStr:showMsg]) {
        
        MyNode *rootNode = [parser getRootNode];
        
        CGSize rSize = [BJGossipTableViewCell getRichTxtSize:self withNode:rootNode withFont:font withMaxWid:BJ_GOSSIP_TEXTMAXWIDTH];
        
        self.gossipView.frame = CGRectMake((self.contentView.frame.size.width-rSize.width)/2, 10, rSize.width, rSize.height);
        
        for (int i = 0; i < [self.lableArray count]; i++) {
            UILabel *itemLable = [self.lableArray objectAtIndex:i];
            [self.gossipView addSubview:itemLable];
        }
        
    }else
    {
        NSInteger lineCount = 0;
        
        NSArray *spArray = [BJGossipTableViewCell splitMsg:showMsg withFont:font withMaxWid:BJ_GOSSIP_TEXTMAXWIDTH];
        
        CGFloat textW = 0.0f;
        
        if ([spArray count] >1) {
            textW = BJ_GOSSIP_TEXTMAXWIDTH;
            self.contentLabel.numberOfLines = 0;
            self.contentLabel.textAlignment = NSTextAlignmentLeft;
            lineCount = [spArray count];
        }else
        {
            self.contentLabel.numberOfLines = 1;
            self.contentLabel.textAlignment = NSTextAlignmentCenter;
            if ([spArray count] == 0) {
                showMsg = @"空消息!";
            }
            CGSize size = [showMsg sizeWithFont:font];
            textW = size.width;
            lineCount = 1;
        }
        
        self.contentLabel.text = showMsg;
        
        self.gossipView.frame = CGRectMake((self.contentView.frame.size.width-(textW+BJ_GOSSIP_MARGIN*2))/2, 10, textW+BJ_GOSSIP_MARGIN*2, BJ_GOSSIP_FONTSIZE*lineCount+BJ_GOSSIP_MARGIN*2+BJ_GOSSIP_LINESPAC*(lineCount-1));
        [self.gossipView addSubview:self.contentLabel];
        self.contentLabel.frame = CGRectMake(BJ_GOSSIP_MARGIN, BJ_GOSSIP_MARGIN, textW , BJ_GOSSIP_FONTSIZE*lineCount+BJ_GOSSIP_LINESPAC*(lineCount-1));
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

+ (CGFloat)cellHeightWithInfo:(id)dic indexPath:(NSIndexPath *)indexPath;
{
    CGFloat height = 0.0f;
    IMMessage *message = dic;
    IMNotificationMessageBody *body = message.getNotificationBody;
    
    UIFont *font = [UIFont systemFontOfSize:BJ_GOSSIP_FONTSIZE];
    
    NSString *showMsg = body.content;
    MyXmlDomParser *parser = [[MyXmlDomParser alloc] init];
    
    if(body.type == eTxtMessageContentType_RICH_TXT && [parser parserStr:showMsg])
    {
        MyNode *rootNode = [parser getRootNode];
        CGSize rSize = [self getRichTxtSize:nil withNode:rootNode withFont:font withMaxWid:BJ_GOSSIP_TEXTMAXWIDTH];
        height = rSize.height+20;
    }else
    {
        NSInteger lineCount = [self getMsgLineCount:showMsg withFont:font withMaxWid:BJ_GOSSIP_TEXTMAXWIDTH];
        if (lineCount == 0) {
            lineCount = 1;
        }
        height = BJ_GOSSIP_FONTSIZE*lineCount+BJ_GOSSIP_MARGIN*2+BJ_GOSSIP_LINESPAC*(lineCount-1)+20;
    }
    
    return height;
}

+(NSInteger)getMsgLineCount:(NSString*)showMsg withFont:(UIFont*)font withMaxWid:(CGFloat)width;
{
    NSInteger count = 0;
    if (showMsg != nil) {
        NSMutableString *subStr = [[NSMutableString alloc] init];
        for (int i=0; i<[showMsg length]; i++) {
            CGSize size = [[NSString stringWithFormat:@"%@%@",subStr,[showMsg substringWithRange:NSMakeRange(i, 1)]] sizeWithFont:font];
            if (size.width>width) {
                if ([subStr length]>0) {
                    count++;
                    subStr = [[NSMutableString alloc] init];
                    i--;
                }else
                {
                    break;
                }
            }else
            {
                [subStr appendString:[showMsg substringWithRange:NSMakeRange(i, 1)]];
            }
        }
        
        if ([subStr length]>0) {
            count++;
        }
    }
    
    return count;
}

+(NSArray*)splitMsg:(NSString*)showMsg withFont:(UIFont*)font withMaxWid:(CGFloat)width;
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    if (showMsg != nil) {
        NSMutableString *subStr = [[NSMutableString alloc] init];
        for (int i=0; i<[showMsg length]; i++) {
            CGSize size = [[NSString stringWithFormat:@"%@%@",subStr,[showMsg substringWithRange:NSMakeRange(i, 1)]] sizeWithFont:font];
            if (size.width>width) {
                if ([subStr length]>0) {
                    [retArray addObject:subStr];
                    subStr = [[NSMutableString alloc] init];
                    i--;
                }else
                {
                    break;
                }
            }else
            {
                [subStr appendString:[showMsg substringWithRange:NSMakeRange(i, 1)]];
            }
        }
        
        if ([subStr length]>0) {
            [retArray addObject:subStr];
        }
    }
    
    return retArray;
}

+(CGSize)getRichTxtSize:(BJGossipTableViewCell*)cell withNode:(MyNode*)node withFont:(UIFont*)font withMaxWid:(CGFloat)maxWidth;
{
    CGFloat width = 0.0f;
    NSInteger lineCount = 0;
    
    MyNode *rootNode = node;
    CGFloat curShowWidth = maxWidth;
    for (int i = 0; i < [rootNode.storageMutableArray count]; i++) {
        NSString *showMsg = nil;
        NSString *hrefLink = nil;
        id object = [rootNode.storageMutableArray objectAtIndex:i];
        if ([object isKindOfClass:[NSString class]]) {
            showMsg = object;
        }else if([object isKindOfClass:[MyNode class]])
        {
            MyNode *itemNode = (MyNode*)object;
            showMsg = [itemNode getNodeValue];
            if ([itemNode.nodeName isEqualToString:@"a"]) {
                hrefLink = [itemNode.nodeAttributes objectForKey:@"href"];
            }
        }
        NSArray *splitA = [BJGossipTableViewCell splitMsg:showMsg withFont:font withMaxWid:curShowWidth];
        if ([splitA count] == 0 && curShowWidth < maxWidth) {
            lineCount++;
            if (width < maxWidth) {
                width = maxWidth;
            }
            curShowWidth = maxWidth;
            splitA = [BJGossipTableViewCell splitMsg:showMsg withFont:font withMaxWid:curShowWidth];
        }
        while ([splitA count]>1) {
            if (cell != nil) {
                NSString *labelText = [splitA objectAtIndex:0];
                CGFloat lableWidth = [labelText sizeWithFont:font].width;
                CustomLable *itemLable = [[CustomLable alloc] initWithFrame:CGRectMake(BJ_GOSSIP_MARGIN+(BJ_GOSSIP_TEXTMAXWIDTH-curShowWidth),BJ_GOSSIP_MARGIN+lineCount*BJ_GOSSIP_FONTSIZE+lineCount*BJ_GOSSIP_LINESPAC,lableWidth , BJ_GOSSIP_FONTSIZE)];
                itemLable.deleagate = cell;
                itemLable.text = labelText;
                if (hrefLink != nil) {
                    [itemLable addHrefLink:hrefLink];
                }
                [cell.lableArray addObject:itemLable];
            }
            
            showMsg = [showMsg substringWithRange:NSMakeRange([[splitA objectAtIndex:0] length], [showMsg length]-[[splitA objectAtIndex:0] length])];
            lineCount++;
            if (width < maxWidth) {
                width = maxWidth;
            }
            curShowWidth = maxWidth;
            splitA = [BJGossipTableViewCell splitMsg:showMsg withFont:font withMaxWid:curShowWidth];
        }
        if ([splitA count]>0) {
            NSString *labelText = [splitA objectAtIndex:0];
            CGFloat lableWidth = [labelText sizeWithFont:font].width;
            if (cell != nil) {
                CustomLable *itemLable = [[CustomLable alloc] initWithFrame:CGRectMake(BJ_GOSSIP_MARGIN+(BJ_GOSSIP_TEXTMAXWIDTH-curShowWidth),BJ_GOSSIP_MARGIN+lineCount*BJ_GOSSIP_FONTSIZE+lineCount*BJ_GOSSIP_LINESPAC,lableWidth , BJ_GOSSIP_FONTSIZE)];
                itemLable.deleagate = cell;
                itemLable.text = labelText;
                if (hrefLink != nil) {
                    [itemLable addHrefLink:hrefLink];
                }
                [cell.lableArray addObject:itemLable];
            }
            
            if (width < lableWidth) {
                width = lableWidth;
            }
            curShowWidth = curShowWidth - lableWidth;
        }
    }
    
    return CGSizeMake(width+BJ_GOSSIP_MARGIN*2, BJ_GOSSIP_FONTSIZE*(lineCount+1)+BJ_GOSSIP_MARGIN*2+BJ_GOSSIP_LINESPAC*lineCount);

}

#pragma mark - CustomLableDelegate
-(void)userHitHrefLink:(CustomLable *)customLable
{
    [[BJIMUrlSchema shareInstance] handleUrl:customLable.href];
}

#pragma mark - set get
- (UILabel *)contentLabel
{
    if (_contentLabel == nil) {
        _contentLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.font = [UIFont systemFontOfSize:BJ_GOSSIP_FONTSIZE];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor colorWithHexString:BJ_GOSSIP_FONTCOLOR];
            label.clipsToBounds = YES;
            label;
        });
        if (_gossipView == nil) {
            _gossipView = [[UIView alloc] initWithFrame:CGRectZero];
            _gossipView.backgroundColor = [UIColor colorWithHexString:BJ_GOOSIP_BACKCOLOR];
            _gossipView.layer.cornerRadius = 2;
        }
        [self.gossipView addSubview:self.contentLabel];
        [self.contentView addSubview:self.gossipView];
    }
    return _contentLabel;
}

@end
