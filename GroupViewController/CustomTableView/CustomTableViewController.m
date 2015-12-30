//
//  CustomTableViewController.m
//  
//
//  Created by wangziliang on 15/11/12.
//

#import "CustomTableViewController.h"
#import "BaseCellMode.h"
#import "SectionMode.h"

@interface CustomTableViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic)CGRect frame;

@end

@implementation CustomTableViewController

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.frame = frame;
        self.Offset = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view = [[UIView alloc] initWithFrame:self.frame];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.tableHeaderView = self.tableHeaderView;
    self.tableView.tableFooterView = self.tableFooterView;
    
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(version >= 7.0f)
    {
        self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    
    self.tableView.sectionIndexColor = [UIColor grayColor];
    [self.view addSubview:self.tableView];
}

-(void)setSections:(NSArray<SectionMode *> *)array
{
    for (int i = 0; i < [self.sectionArray count]; i++) {
        SectionMode *itemMode = [self.sectionArray objectAtIndex:i];
        if ([self.sectionArray containsObject:itemMode]) {
            itemMode.customTableViewController = nil;
        }
    }
    [self.sectionArray removeAllObjects];
    [self.sectionArray addObjectsFromArray:array];
    for (int i = 0; i < [array count]; i++) {
        SectionMode *itemMode = [array objectAtIndex:i];
        itemMode.customTableViewController = self;
    }
    [self.tableView reloadData];
}

-(void)insertSections:(NSArray<SectionMode *> *)array withInsertSection:(SectionMode*)mode withInsertType:(ArrayInsertPosition)positon
{
    NSMutableIndexSet *sets = [[NSMutableIndexSet alloc] init];
    NSInteger sectionIndex = [self.sectionArray indexOfObject:mode];
    if (sectionIndex >= 0) {
        if (positon == ArrayInsertPosition_After) {
            sectionIndex++;
        }
        for (int i = 0; i < [array count]; i++) {
            SectionMode *itemMode = [array objectAtIndex:i];
            itemMode.customTableViewController = self;
            [sets addIndex:sectionIndex+i];
        }
        [self.sectionArray insertObjects:array atIndexes:sets];
        [self.tableView insertSections:sets withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)addSections:(NSArray<SectionMode *> *)array
{
    NSMutableIndexSet *sets = [[NSMutableIndexSet alloc] init];
    NSInteger sectionIndex = [self.sectionArray count];
    for (int i = 0; i < [array count]; i++) {
        SectionMode *itemMode = [array objectAtIndex:i];
        itemMode.customTableViewController = self;
        [sets addIndex:sectionIndex+i];
    }
    [self.sectionArray insertObjects:array atIndexes:sets];
    [self.tableView insertSections:sets withRowAnimation:UITableViewRowAnimationFade];
}

-(void)removeSections:(NSArray<SectionMode *> *)array
{
    NSMutableIndexSet *sets = [[NSMutableIndexSet alloc] init];
    for (int i = 0; i < [array count]; i++) {
        SectionMode *itemMode = [array objectAtIndex:i];
        if ([self.sectionArray containsObject:itemMode]) {
            itemMode.customTableViewController = nil;
            NSInteger sectionIndex = [self.sectionArray indexOfObject:itemMode];
            [sets addIndex:sectionIndex];
        }
    }
    [self.sectionArray removeObjectsAtIndexes:sets];
    [self.tableView deleteSections:sets withRowAnimation:UITableViewRowAnimationFade];
}

-(CGPoint)getCurOffSetPoint
{
    return self.tableView.contentOffset;
}

-(void)setCurOffSetPoint:(CGPoint)point
{
    self.tableView.contentOffset = point;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    if (offset.y>=(scrollView.contentSize.height-scrollView.frame.size.height)) {
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(userScrollBottom)])
        {
            [self.delegate userScrollBottom];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SectionMode *itemMode = [self.sectionArray objectAtIndex:section];
    if (itemMode != nil) {
        return [itemMode getRowsCount];
    }else
    {
        return 0;
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.sectionArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    SectionMode *itemMode = [self.sectionArray objectAtIndex:section];
    if (itemMode != nil) {
        return itemMode.headerHeight;
    }else
    {
        return 0;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SectionMode *itemMode = [self.sectionArray objectAtIndex:section];
    if (itemMode != nil) {
        return itemMode.headerView;
    }else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    SectionMode *itemMode = [self.sectionArray objectAtIndex:section];
    if (itemMode != nil) {
        return itemMode.footerHeight;
    }else
    {
        return 0;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    SectionMode *itemMode = [self.sectionArray objectAtIndex:section];
    if (itemMode != nil) {
        return itemMode.footerView;
    }else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SectionMode *itemMode = [self.sectionArray objectAtIndex:indexPath.section];
    BaseCellMode *itemCellMode = [[itemMode getRows] objectAtIndex:indexPath.row];
    return [itemCellMode getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SectionMode *itemMode = [self.sectionArray objectAtIndex:indexPath.section];
    BaseCellMode *itemCellMode = [[itemMode getRows] objectAtIndex:indexPath.row];
    
    BaseModeCell *cell = [tableView dequeueReusableCellWithIdentifier:[itemCellMode getCellIdentifier]];
    
    if (cell == nil) {
        cell = [itemCellMode createModeCell];
    }
    
    [cell setMyCellMode:itemCellMode];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    SectionMode *itemMode = [self.sectionArray objectAtIndex:indexPath.section];
    BaseCellMode *itemCellMode = [[itemMode getRows] objectAtIndex:indexPath.row];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userHitCellMode:)]) {
        [self.delegate userHitCellMode:itemCellMode];
    }
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionTitles;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(index+self.Offset<0)
    {
        return 0;
    }else if (index+self.Offset >= [self.sectionArray count])
    {
        return [self.sectionArray count] - 1;
    }else
    {
        return index+self.Offset;
    }
}

-(NSMutableArray*)sectionArray
{
    if (_sectionArray == nil) {
        _sectionArray = [[NSMutableArray alloc] init];
    }
    return _sectionArray;
}

-(void)setTableHeaderView:(UIView *)tableHeaderView
{
    _tableHeaderView = tableHeaderView;
    if (self.tableView != nil) {
        self.tableView.tableHeaderView = _tableHeaderView;
    }
}

- (void)setTableFooterView:(UIView *)tableFooterView
{
    _tableFooterView = tableFooterView;
    if (self.tableView != nil) {
        self.tableView.tableFooterView = _tableFooterView;
    }
}

@end
