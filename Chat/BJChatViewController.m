//
//  ChatViewController.m
//  BJHL-IM-iOS-SDK
//
//  Created by Randy on 15/7/22.
//  Copyright (c) 2015年 YangLei-bjhl. All rights reserved.
//

#import "BJChatViewController.h"
#import <IMMessage.h>
#import "BJChatCellFactory.h"
#import <BJHL-IM-iOS-SDK/BJIMManager.h>
#import <Conversation+DB.h>

#import "BJChatInputBarViewController.h"
#import "BJSendMessageHelper.h"
#import "BJChatAudioPlayerHelper.h"
#import "IMMessage+ViewModel.h"
#import <BJIMManager.h>
#import <IMMessage+DB.h>

#import "BJChatTimeCell.h"

#import "SRRefreshView.h"

#import <NSDate+Category.h>
#import "BJChatUtilsMacro.h"
#import "UIResponder+BJIMChatRouter.h"
#import "IMMessage+ViewModel.h"
#import "MBProgressHUD+Simple.h"
#import  <NSError+BJIM.h>
#import "BJChatViewController+BrowserHelper.h"
#import <NSDateFormatter+Category.h>
#import <UIView+Basic.h>
#import <UIColor+Util.h>

#import "BJChatLoadMoreHeadView.h"

const int BJ_Chat_Time_Interval = 5;

@interface BJChatViewController ()<UITableViewDataSource,UITableViewDelegate,
IMReceiveNewMessageDelegate,
IMLoadMessageDelegate,
BJChatInputProtocol,
BJSendMessageProtocol,
IMDeliveredMessageDelegate,
IMGroupProfileChangedDelegate,
IMUserInfoChangedDelegate>
{
    BOOL _isFirstAppear; //生命周期第一次判断
    BOOL _hasPreparedMessages;
}

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *messageList;

@property (strong, nonatomic) Conversation *conversation;

@property (strong, nonatomic) NSMutableDictionary *messageHeightDic;

/**
 *  输入区域的控制
 */
@property (strong, nonatomic) BJChatInputBarViewController *inputController;

@property (strong, nonatomic)  BJChatLoadMoreHeadView *chatHeadView;

@property (strong, nonatomic) UILabel *nonRecordLable;

@property (assign, nonatomic) BOOL isLoadMore;

@property (strong, nonatomic) UIWebView *webView;//webView实现打电话,可以直接返回到应用

@end

@implementation BJChatViewController

- (void)dealloc
{
    [[BJIMManager shareInstance] stopChat];
    [[BJChatAudioPlayerHelper sharedInstance] stopPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view removeObserver:self forKeyPath:@"frame"];
    
}

- (instancetype)initWithChatInfo:(BJChatInfo *)chatInfo;
{
    self = [super init];
    if (self) {
        _chatInfo = chatInfo;
        _isFirstAppear = YES;
        [[BJSendMessageHelper sharedInstance] addDelegate:self];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.chatInfo.chat_t == eChatType_GroupChat) {
        [[BJIMManager shareInstance] startChatToGroup:self.chatInfo.getToId];
    }
    else
    {
        [[BJIMManager shareInstance] startChatToUserId:self.chatInfo.getToId role:self.chatInfo.getToRole];
    }
    [self.conversation resetUnReadNum];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    }
    
    if (_isFirstAppear) {
        _isFirstAppear = NO;
        [self viewWillAppearFirstHandle];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[BJIMManager shareInstance] stopChat];
    [[BJChatAudioPlayerHelper sharedInstance] stopPlayer];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = YES;
    }
}

//第一次调用viewWillAppear
- (void)viewWillAppearFirstHandle
{
    //    [self scrollViewToBottom:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroud) name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //    self.view.autoresizesSubviews = NO;
    //    self.view.autoresizingMask = UIViewAutoresizingNone;
    
    [[BJIMManager shareInstance] addReceiveNewMessageDelegate:self];
    [[BJIMManager shareInstance] addLoadMoreMessagesDelegate:self];
    [[BJIMManager shareInstance] addDeliveryMessageDelegate:self];
    if ([self.chatInfo getContactType] == BJContact_Group) {
        [[BJIMManager shareInstance] addGroupProfileChangedDelegate:self];
    }
    [[BJIMManager shareInstance] addUserInfoChangedDelegate:self];
    
    //    NSArray *array = [[BJIMManager shareInstance] loadMessageFromMinMsgId:0 inConversation:self.conversation];
    //    [self addNewMessages:array isForward:NO];
    //
    //    if ([array count] > 0 && self.conversation && self.conversation.chat_t == eChatType_GroupChat)
    //    {
    [[BJIMManager shareInstance] loadMessageFromMinMsgId:0 inConversation:self.conversation];
    //    }
    
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.inputController.view];
    [self addChildViewController:self.inputController];
    [self.inputController didMoveToParentViewController:self];
    [self updateSubViewFrame];
    [self.tableView addSubview:self.chatHeadView];
    
    //    {
    //        IMMessage *cardMessage = [[IMMessage alloc] init];
    //        cardMessage.chat_t = eChatType_GroupChat;
    //        cardMessage.msg_t = eMessageType_TXT;
    //        IMTxtMessageBody*card = [[IMTxtMessageBody alloc] init];
    //        card.content = @"http://www.baidu.com";
    //        cardMessage.messageBody = card;
    //        [self addNewMessages:@[cardMessage] isForward:NO];
    //    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - 消息操作方法
- (NSInteger)addNewMessages:(NSArray *)messages isForward:(BOOL)forward;
{
    if (messages.count <= 0) {
        return 0;
    }
    
    NSMutableArray *mutMessages = [[NSMutableArray alloc] initWithArray:messages];
    IMMessage *lastMessage = nil;
    if (!forward && self.messageList.count>0) {
        lastMessage = self.messageList.lastObject;
    }
    else if (forward || self.messageList.count<=0)
    {
        IMMessage *firstMessage = messages.firstObject;
        [mutMessages insertObject:[self customformattedTime:[NSDate dateWithTimeIntervalSince1970:firstMessage.createAt]] atIndex:0];
    }
    
    for (IMMessage *oneMessage in messages) {
//        [oneMessage markRead];
        if (lastMessage) {
            long long minute = ([NSDate dateWithTimeIntervalSince1970:oneMessage.createAt].minute/BJ_Chat_Time_Interval - [NSDate dateWithTimeIntervalSince1970:lastMessage.createAt].minute/BJ_Chat_Time_Interval);//两条消息的时间分单位间隔超过5，则加一个时间显示
            if (minute > 0) {
                [mutMessages insertObject:[self customformattedTime:[NSDate dateWithTimeIntervalSince1970:oneMessage.createAt]] atIndex:[mutMessages indexOfObject:oneMessage]];
                lastMessage = oneMessage;
            }
        }
        else
            lastMessage = oneMessage;
    }
    
    if (forward) {
        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, mutMessages.count)];
        [self.messageList insertObjects:mutMessages atIndexes:set];
        [self.tableView reloadData];
    }
    else
    {
        NSInteger curIndex = self.messageList.count;
        [self.messageList addObjectsFromArray:mutMessages];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i=0; i<mutMessages.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i+curIndex inSection:0]];
        }
        if (curIndex>0)//已经有消息了，通过插入方式
        {
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
        else //列表没有消息，直接reload就行
        {
            [self.tableView reloadData];
        }
    }
    return [mutMessages count];
    
}

//时间处理函数,统一使用UTC时间，计算出来的时间也是UTC时间。
-(NSString*)customformattedTime:(NSDate*)time
{
    NSDateFormatter* formatter = [NSDateFormatter dateFormatter];
    [formatter setDateFormat:@"YYYYMMdd"];
    NSString * dateNow = [formatter stringFromDate:[NSDate date]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[[dateNow substringWithRange:NSMakeRange(6,2)] intValue]];
    [components setMonth:[[dateNow substringWithRange:NSMakeRange(4,2)] intValue]];
    [components setYear:[[dateNow substringWithRange:NSMakeRange(0,4)] intValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:components]; //今天 0点时间
    
    NSInteger hour = [time hoursAfterDate:date];
    NSDateFormatter *dateFormatter = nil;
    NSString *ret = @"";
    
    if(hour>=0)
    {
        if (hour<6) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"凌晨HH:mm"];
        }else if(hour<12){
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"上午HH:mm"];
        }else if(hour<18){
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"下午HH:mm"];
        }else{
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"晚上HH:mm"];
        }
    }else
    {
        NSDateComponents *yComponents = [[NSDateComponents alloc] init];
        [yComponents setDay:[[dateNow substringWithRange:NSMakeRange(6,2)] intValue]-1];
        [yComponents setMonth:[[dateNow substringWithRange:NSMakeRange(4,2)] intValue]];
        [yComponents setYear:[[dateNow substringWithRange:NSMakeRange(0,4)] intValue]];
        NSDate *yDate = [gregorian dateFromComponents:yComponents]; //昨天 0点时间
        
        hour = [time hoursAfterDate:yDate];
        if (hour>=0) {
            if (hour<6) {
                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"昨天 凌晨HH:mm"];
            }else if(hour<12){
                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"昨天 上午HH:mm"];
            }else if(hour<18){
                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"昨天 下午HH:mm"];
            }else{
                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"昨天 晚上HH:mm"];
            }
        }else
        {
            NSString *curDate = [formatter stringFromDate:time];
            NSDateComponents *cComponents = [[NSDateComponents alloc] init];
            [cComponents setDay:[[curDate substringWithRange:NSMakeRange(6,2)] intValue]];
            [cComponents setMonth:[[curDate substringWithRange:NSMakeRange(4,2)] intValue]];
            [cComponents setYear:[[curDate substringWithRange:NSMakeRange(0,4)] intValue]];
            NSDate *cDate = [gregorian dateFromComponents:cComponents]; //当天 0点时间
            
            hour = [time hoursAfterDate:cDate];
            if (hour<6) {
                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"MM月dd日 凌晨HH:mm"];
            }else if(hour<12){
                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"MM月dd日 上午HH:mm"];
            }else if(hour<18){
                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"MM月dd日 下午HH:mm"];
            }else{
                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"MM月dd日 晚上HH:mm"];
            }
        }
    }
    
    /*
     保留代码(获取当前系统时间设置，是否是24小时制)
     NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
     NSRange containsA = [formatStringForHours rangeOfString:@"a"];
     BOOL hasAMPM = containsA.location != NSNotFound;
     */
    
    ret = [dateFormatter stringFromDate:time];
    return ret;
}

- (void)loadMoreMessages
{
    NSString *msgId ;
    IMMessage *message = nil;
    int i=0 ;
    while (![message isKindOfClass:[IMMessage class]] && [self.messageList count] > i) {
        message = [self.messageList objectAtIndex:i];
        i++;
    }
        msgId = message.msgId;
    if (msgId.length>0) {
        self.isLoadMore = YES;
        [[BJIMManager shareInstance] loadMessageFromMinMsgId:msgId inConversation:self.conversation];
    }
}

#pragma mark - observer 通知 进入前台，后台等
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateSubViewFrame];
}

- (void)applicationDidEnterBackgroud
{
    [[BJIMManager shareInstance] stopChat];
}

- (void)applicationDidBecomeActive
{
    if (self.chatInfo.chat_t == eChatType_GroupChat) {
        [[BJIMManager shareInstance] startChatToGroup:self.chatInfo.getToId];
    }
    else
    {
        [[BJIMManager shareInstance] startChatToUserId:self.chatInfo.getToId role:self.chatInfo.getToRole];
    }
}

#pragma mark - 视图更新
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self keyBoardHidden];
}

- (void)updateSubViewFrame
{
    CGRect rect = self.inputController.view.frame;
    rect.origin.y = self.view.bounds.size.height - rect.size.height;
    self.inputController.view.frame = rect;
    
    rect = self.view.bounds;
    rect.size.height -= self.inputController.view.frame.size.height;
    self.tableView.frame = rect;
}

/**
 *  分析是否要滑动到最下面规则 如果偏移量距下不超过15，则 YES
 *
 *  @return
 */
- (BOOL)analyzeScrollViewShouldToBottom
{
    if (self.tableView.isDecelerating || self.tableView.isDragging || self.tableView.isTracking) {
        return NO;
    }
    CGFloat leftContentHeight = self.tableView.contentSize.height - self.tableView.contentOffset.y;
    CGFloat viewHeight = self.tableView.frame.size.height - self.tableView.contentInset.bottom;
    if (leftContentHeight <  viewHeight*1.6)
    { //消息显示停留在视图半屏一下才自定上移动
        return YES;
    }
    return NO;
}

- (void)scrollViewToBottom:(BOOL)animated needDelay:(BOOL)delay
{
    WS(weakSelf);
    if (delay) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSInteger index = weakSelf.messageList.count-1;
            if (index>0) {
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
                
            }
        });
    }
    else
    {
        NSInteger index = weakSelf.messageList.count-1;
        if (index>0) {
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
            
        }
    }

}

- (void)reloadWithMessageForDeviveredChange:(IMMessage *)message
{
    NSInteger index = [self.messageList indexOfObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    if (message.msg_t == eMessageType_CARD && message.deliveryStatus == eMessageStatus_Send_Succ) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    else
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell conformsToProtocol:@protocol(BJChatViewCellProtocol)]) {
            id<BJChatViewCellProtocol>chatCell = (id<BJChatViewCellProtocol>)cell;
            [chatCell setCellInfo:message indexPath:indexPath];
        }
    }
}


- (void)showBigImageWithMessage:(IMMessage *)message
{
    [self.inputController endEditing:YES];
    [self showBrowserWithImages:@[message.imageURL]];
}

- (void)cardCellTapWithMessage:(IMMessage *)message
{
    NSString *url = [message cardUrl];
    if (self.openURL != nil) {
        self.openURL(url);
    }
}

- (void)linkCellTapWithMessage:(NSString *)str
{
    if (self.openURL != nil) {
        self.openURL(str);
    }
}

- (void)phoneTapWithPhoneNum:(NSString *)phoneNum
{
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNum]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
}

- (void)audioCellTapWithMessage:(IMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    if (message.isPlaying) {
        [[BJChatAudioPlayerHelper sharedInstance] stopPlayerWithMessage:message];
    }
    else
    {
        [message markPlayed];
        [[BJChatAudioPlayerHelper sharedInstance] startPlayerWithMessage:message callback:^(NSError *error) {
            if (error !=nil) {
                [MBProgressHUD showErrorThenHide:[error bjim_Reason] toView:weakSelf.view onHide:nil];
            }
            [weakSelf.tableView reloadData];
        }];
    }
    [self.tableView reloadData];
}

#pragma mark - 键盘相关

// 点击背景隐藏
-(void)keyBoardHidden
{
    [self.inputController endEditing:YES];
}

#pragma mark - message delegate

- (void)didReceiveNewMessages:(NSArray *)newMessages
{
    for (NSInteger index = 0; index < [newMessages count]; ++index)
    {
        IMMessage *msg = [newMessages objectAtIndex:index];
        if (msg.conversationId == self.conversation.rowid)
        {
            [self addNewMessages:@[msg] isForward:NO];
            
            if ([self analyzeScrollViewShouldToBottom]) {
                [self scrollViewToBottom:YES needDelay:YES];
            }
        }
    }
}

- (void)didPreLoadMessages:(NSArray *)preMessages conversation:(Conversation *)conversation
{
    if (conversation.rowid == self.conversation.rowid) {
        [self addNewMessages:preMessages isForward:NO];
        [self scrollViewToBottom:NO needDelay:NO];
        _hasPreparedMessages = YES;
    }
}

- (void)didLoadMessages:(NSArray *)messages conversation:(Conversation *)conversation hasMore:(BOOL)hasMore
{
    if (conversation.rowid == self.conversation.rowid) {
        if (_hasPreparedMessages)
        {
            [self.messageList removeAllObjects];
            _hasPreparedMessages = NO;
        }

        if (self.isLoadMore) {
            NSUInteger lastCount = self.messageList.count;
            [self addNewMessages:messages isForward:YES];
            NSUInteger index = self.messageList.count- lastCount;
            if (index>=self.messageList.count) {
                index = self.messageList.count - 1;
            }
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        else
        {
            [self addNewMessages:messages isForward:NO];
            [self scrollViewToBottom:NO needDelay:NO];
        }
        [self.chatHeadView setCanLoadMore:hasMore];
        [self.chatHeadView bjChatLoadMoreHeadViewScrollViewDataSourceDidFinishedLoading:self.tableView];
        //检测是否有记录
        [self checkOutRecords:YES];
    }
}

- (void)willDeliveryMessage:(IMMessage *)message;
{
    [self reloadWithMessageForDeviveredChange:message];
}

- (void)didDeliveredMessage:(IMMessage *)message
                  errorCode:(NSInteger)errorCode
                      error:(NSString *)errorMessage;
{
    [self reloadWithMessageForDeviveredChange:message];
    //如果最后一张是自己发送的卡片，则消息类型会更新，高度会变化
    if ([self analyzeScrollViewShouldToBottom] &&
        message.msg_t == eMessageType_CARD &&
        [self.messageList lastObject] == message &&
        [message isMySend] && errorCode == eError_suc) {
        [self scrollViewToBottom:YES needDelay:NO];
    }
    if (errorCode != eError_suc &&  errorMessage.length > 0) {
        [MBProgressHUD showWindowErrorThenHide:errorMessage];
    }
}

- (void)willSendMessage:(IMMessage *)message;
{
    if (message.chat_t == eChatType_Chat) {
        if (message.receiver == self.chatInfo.getToId && message.receiverRole == self.chatInfo.getToRole) {
            [self addNewMessages:@[message] isForward:NO];
            [self scrollViewToBottom:YES needDelay:YES];
        }
    }
    else if (message.chat_t == eChatType_GroupChat)
    {
        if (message.receiver == self.chatInfo.getToId) {
            [self addNewMessages:@[message] isForward:NO];
            [self scrollViewToBottom:YES needDelay:YES];
        }
    }
}

- (void)didUserInfoChanged:(User *)user;
{
    if ([self.chatInfo.chatToUser isEqual:user]) {
        [self.tableView reloadData];
    }
}

- (void)didGroupProfileChanged:(Group *)group;
{
    if ([self.chatInfo.chatToGroup isEqual:group]) {
        [self.tableView reloadData];
    }
}

#pragma mark - BJChatInputProtocol
/**
 *  高度变到toHeight
 */
- (void)didChangeFrameToHeight:(CGFloat)toHeight;
{
    CGFloat offset = ceilf((toHeight-[BJChatInputBarViewController defaultHeight]));
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, offset, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, offset, 0);
    
    if(toHeight > [BJChatInputBarViewController defaultHeight]+10){
        [self scrollViewToBottom:NO needDelay:NO];
        
    }
}

#pragma mark - UIResponder actions
- (void)bjim_routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    IMMessage *message = [userInfo objectForKey:kBJRouterEventUserInfoObject];
    if ([eventName isEqualToString:kBJRouterEventChatCellHeadTapEventName]){
        //点击头像，添加响应操作
    }else if ([eventName isEqualToString:kBJRouterEventImageBubbleTapEventName]){
        [self showBigImageWithMessage:message];
    }
    else if ([eventName isEqualToString:kBJResendButtonTapEventName])
    {
        [[BJIMManager shareInstance] retryMessage:message];
        if([self.messageList lastObject] != message)
        {
            NSInteger index = [self.messageList indexOfObject:message];
            [self.messageList removeObjectAtIndex:index];
            [self.messageList addObject:message];
            [self.tableView beginUpdates];
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] toIndexPath:[NSIndexPath indexPathForRow:self.messageList.count-1 inSection:0]];
            [self.tableView endUpdates];
            
            [self scrollViewToBottom:YES needDelay:NO];
        }
    }
    else if ([eventName isEqualToString:kBJRouterEventAudioBubbleTapEventName])
    {
        [self audioCellTapWithMessage:message];
    }
    else if ([eventName isEqualToString:kBJRouterEventCardEventName])
    {
        [self cardCellTapWithMessage:message];
    }
    else if ([eventName isEqualToString:kBJRouterEventLinkName])
    {
        [self linkCellTapWithMessage:[userInfo objectForKey:kBJRouterEventUserInfoObject]];
    }
    else if ([eventName isEqualToString:kBJRouterEventPhoneCall])
    {
        [self phoneTapWithPhoneNum:[userInfo objectForKey:kBJRouterEventUserInfoObject]];
    }
}

#pragma mark - BJChatLoadMoreHeadViewDelegate

- (void)bjChatLoadMoreHeadViewDidTriggerRefresh:(BJChatLoadMoreHeadView *)view
{
    [self loadMoreMessages];
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.chatHeadView) {
        [self.chatHeadView scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self keyBoardHidden];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    if (self.chatHeadView) {
        [self.chatHeadView scrollViewDidEndDecelerating:scrollView];
    }
    
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self checkOutRecords:NO];
    return self.messageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMMessage *message = [self.messageList objectAtIndex:indexPath.row];
    
    if ([message isKindOfClass:[NSString class]]) {
        BJChatTimeCell *timeCell = (BJChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCellTime"];
        if (timeCell == nil) {
            timeCell = [[BJChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCellTime"];
            timeCell.backgroundColor = [UIColor clearColor];
            timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        timeCell.textLabel.text = (NSString *)message;
        
        return timeCell;
    }
    
    UITableViewCell<BJChatViewCellProtocol> *cell = [tableView dequeueReusableCellWithIdentifier:[[BJChatCellFactory sharedInstance] cellIdentifierWithMessageType:message.msg_t]];
    if (cell == nil) {
        cell = [[BJChatCellFactory sharedInstance] cellWithMessageType:message.msg_t];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setCellInfo:message indexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMMessage *message = [self.messageList objectAtIndex:indexPath.row];
    
    if ([message isKindOfClass:[NSString class]]) {
        return 40;
    }
    else
    {
        CGFloat Height = 0;
        
        //message的id自己发的不一定已经创建 需要以其他值为键
        //    if ([self.messageHeightDic objectForKey:@(message.msgId)]) {
        //        Height = [[self.messageHeightDic objectForKey:@(message.msgId)] floatValue];
        //    }
        //    else
        //    {
        Height = [[BJChatCellFactory sharedInstance] cellHeightWithMessage:message indexPath:indexPath];
        //        [self.messageHeightDic setObject:@(Height) forKeyedSubscript:message.msgId];
        //    }
        return Height;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - set get
- (Conversation *)conversation
{
    if (_conversation == nil) {
        if (self.chatInfo.chat_t == eChatType_GroupChat) {
            _conversation = [[BJIMManager shareInstance] getConversationGroupId:self.chatInfo.getToId];
            if (_conversation) {
                self.title = _conversation.chatToGroup.groupName;
            }
        }
        else
        {
            _conversation = [[BJIMManager shareInstance] getConversationUserId:self.chatInfo.getToId role:self.chatInfo.getToRole];
            if (_conversation) {
                self.title = _conversation.chatToUser.name;
            }
        }
    }
    return _conversation;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
    }
    return _tableView;
}


- (NSMutableArray *)messageList
{
    if (_messageList == nil) {
        _messageList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _messageList;
}

- (NSMutableDictionary *)messageHeightDic
{
    if (_messageHeightDic == nil) {
        _messageHeightDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _messageHeightDic;
}

- (BJChatInputBarViewController *)inputController
{
    if (_inputController == nil) {
        _inputController = [[BJChatInputBarViewController alloc] initWithChatInfo:self.chatInfo];
        _inputController.delegate = self;
    }
    return _inputController;
}

- (UILabel *)nonRecordLable
{
    if (!_nonRecordLable) {
        _nonRecordLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, self.view.current_w, 30)];
        [_nonRecordLable setBackgroundColor:[UIColor clearColor]];
        [_nonRecordLable setTextAlignment:NSTextAlignmentCenter];
        [_nonRecordLable setTextColor:[UIColor colorWithHexString:@"#6d6d6e"]];
        [_nonRecordLable setText:@"暂无聊天消息"];
        [_nonRecordLable setFont:[UIFont systemFontOfSize:16]];
    }
    return _nonRecordLable;
}

-(BJChatLoadMoreHeadView *)chatHeadView
{
    if (!_chatHeadView) {
        _chatHeadView = [[BJChatLoadMoreHeadView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.size.width, 40)];
        [_chatHeadView setDelegate:self];
    }
    return _chatHeadView;
}

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc]initWithFrame:CGRectZero];
    }
    return _webView;
}

#pragma mark - Internal Helpers
/*!
 *  @author Mrlu, 15-08-11 12:08
 *
 *  @brief 检测是否有消息
 */
- (void)checkOutRecords:(BOOL)show
{
    if ([self.messageList count]==0) {
        if (!self.nonRecordLable.superview && show) {
            [self.tableView addSubview:self.nonRecordLable];
        }
    } else {
        [self.nonRecordLable removeFromSuperview];
    }
}
@end

