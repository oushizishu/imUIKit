//
//  BJChatInputFastReplyViewController.m
//  BJEducation_Institution
//
//  Created by Lina on 16/11/2.
//  Copyright © 2016年 com.bjhl. All rights reserved.
//

#import "BJChatInputFastReplyViewController.h"
#import "BJFastReplyView.h"
#import "BJFastReplyTableViewCell.h"
#import "BJFastReplyViewController.h"
#import "BJIMKitNetworkManager.h"

@interface BJChatInputFastReplyViewController ()<BJFastReplyViewDelegate>
@property (nonatomic, strong) BJFastReplyView *replayView;
@property (nonatomic, strong)NSMutableArray  *replyArray;

@end

@implementation BJChatInputFastReplyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200);
    self.view.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.replayView];
    _replyArray = [NSMutableArray array];

    [self requstServer];
    
    //增加线
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    topLineView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    [self.view addSubview:topLineView];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)sendFaceMessage:(NSString *)str
{
    [BJSendMessageHelper sendTextMessage:str chatInfo:self.chatInfo];
}

- (BJFastReplyView *)replayView{
    if (!_replayView) {
        _replayView = [[BJFastReplyView alloc] initWithFrame:CGRectMake(0, 0,self.view.current_w, 200) isCanLeftSlide:NO];
        [_replayView setDelegate:self];
        [_replayView.tableView setTableFooterView:[self replyBottomView]];
    }
    return _replayView;
}

- (UIView *)replyBottomView{
    
    UIView  *replyBottomView = [[UIView alloc]initWithFrame:CGRectMake(0,0, _replayView.current_w, 44)];
    [replyBottomView setBackgroundColor:[UIColor clearColor]];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(10, 0, _replayView.current_w - 20, 44)];
    [btn setTitle:@"自定义快捷回复 >" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [btn setTitleColor:[UIColor bj_blue] forState:UIControlStateNormal];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btn addTarget:self action:@selector(gotoSetFastReplay) forControlEvents:UIControlEventTouchUpInside];
    
    [replyBottomView addSubview:btn];
    return replyBottomView;
    
}

- (void)gotoSetFastReplay{
    
    BJFastReplyViewController *vc = [[BJFastReplyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)requstServer{
    weakifyself
    [BJIMKitNetworkManager  getQuickResponseList:^(id response, NSDictionary *responseHeaders, BJCNRequestParams *params) {
        strongifyself
        
        NSDictionary *dic = [(NSDictionary *)response   valueForKey:@"data"];
        [self updateServerData:dic];
    } failure:^(NSError *error, BJCNRequestParams *params) {
        strongifyself
        [MBProgressHUD showErrorThenHide:error.reason toView:self.view onHide:nil];
        
    }];
}

- (void)updateServerData:(NSDictionary *)result{
    
    [_replyArray removeAllObjects];
    NSArray *list  = [result valueForKey:@"list"];
    NSArray *modelArray = [FastReplyModel initWithNSArrayDic:list];
    _replyArray = [NSMutableArray arrayWithArray:modelArray];
    _replayView.infoArray = _replyArray;

}

#pragma mark - BJFastReplyViewDelegate

- (void)fastReplyViewWith:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FastReplyModel *model = [_replyArray objectAtIndex:indexPath.row];

    NSString *str  = model.content;
    if (self.actionBlock) {
        self.actionBlock(str);
    }
    //    [self sendFaceMessage:str];
}

- (UITableViewCell *)fastReplyViewWith:(BJFastReplyView *)replyView tableView:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"Cell";
    BJFastReplyTableViewCell *cell = (BJFastReplyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[BJFastReplyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        if(replyView.isCanLeftSlide){
            cell.rightUtilityButtons = [replyView rightButtons];
        }
        cell.delegate = replyView;
    }
    FastReplyModel *model = [_replyArray objectAtIndex:indexPath.row];
    cell.fastModel = model;
    return cell;
    
}

- (CGFloat)fastReplyViewWith:(BJFastReplyView *)replyView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FastReplyModel *model = [_replyArray objectAtIndex:indexPath.row];
    return [BJFastReplyTableViewCell heightForStr:model.content];
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

@end
