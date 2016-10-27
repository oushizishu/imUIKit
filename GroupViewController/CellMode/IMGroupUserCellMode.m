//
//  IMGroupUserCellMode.m
//
//  Created by wangziliang on 15/12/4.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import "IMGroupUserCellMode.h"
#import "IMSingleSelectDialog.h"

#import <BJHL-IM-iOS-SDK/IMEnvironment.h>
#import "IMLinshiTool.h"

#import <BJHL-Foundation-iOS/BJHL-Foundation-iOS.h>
#import <BJHL-Kit-iOS/BJHL-Kit-iOS.h>

//等比例裁剪
#define RetinaSize(size) (int)([UIScreen mainScreen].scale*size)

#define CuteImageUrl(oriUrl,w,h) (oriUrl?[NSString stringWithFormat:@"%@@0e_%dw_%dh_1c_0i_1o_90Q_1x.png",oriUrl,(int)RetinaSize(w),(int)RetinaSize(h)]:oriUrl)

@interface IMGroupUserCell()

@property (strong ,nonatomic) UIView *cellView;
@property (strong ,nonatomic) UIImageView *faceViewImage;
@property (strong ,nonatomic) UILabel *userNameL;
@property (strong ,nonatomic) UILabel *userRoleL;
@property (strong ,nonatomic) UIView *deleteView;
@property (strong ,nonatomic) UIButton *deleteBtn;
@property (strong ,nonatomic) UIView *moreView;
@property (strong ,nonatomic) UIButton *moreBtn;

@end

@implementation IMGroupUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //设置cell没有选中效果
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        UISwipeGestureRecognizer *lSwipG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        [lSwipG setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [self addGestureRecognizer:lSwipG];
        
        UISwipeGestureRecognizer *rSwipG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        [rSwipG setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [self addGestureRecognizer:rSwipG];
        
        CGRect sRect = [UIScreen mainScreen].bounds;
        
        self.cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sRect.size.width+75*2, 55)];
        [self addSubview:self.cellView];
        
        self.faceViewImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 36, 36)];
        [self.faceViewImage.layer setCornerRadius:2.0f];
        self.faceViewImage.layer.masksToBounds = YES;
        self.faceViewImage.backgroundColor = [UIColor whiteColor];
        [self.cellView addSubview:self.faceViewImage];
        
        self.userNameL = [[UILabel alloc] initWithFrame:CGRectZero];
        self.userNameL.font = [UIFont systemFontOfSize:14.0f];
        self.userNameL.textColor = [UIColor bjck_colorWithHexString:IMCOLOT_GREY600];
        self.userNameL.textAlignment = NSTextAlignmentLeft;
        [self.cellView addSubview:self.userNameL];
        
        self.userRoleL = [[UILabel alloc] initWithFrame:CGRectZero];
        self.userRoleL.font = [UIFont systemFontOfSize:14.0f];
        self.userRoleL.textColor = [UIColor bjck_colorWithHexString:IMCOLOT_GREY400];
        self.userRoleL.textAlignment = NSTextAlignmentLeft;
        [self.cellView addSubview:self.userRoleL];
        
        self.deleteView = [[UIView alloc] initWithFrame:CGRectMake(sRect.size.width, 0, 75, 55)];
        self.deleteView.backgroundColor = [UIColor bjck_colorWithHexString:@"#f95e5e"];
        [self.cellView addSubview:self.deleteView];
        self.deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 18, 55, 20)];
        [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        self.deleteBtn.backgroundColor = [UIColor clearColor];
        [self.deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteView addSubview:self.deleteBtn];
        
        self.moreView = [[UIView alloc] initWithFrame:CGRectMake(sRect.size.width+75, 0, 75, 55)];
        self.moreView.backgroundColor = [UIColor bjck_colorWithHexString:@"#6d6d6e"];
        [self.cellView addSubview:self.moreView];
        self.moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 18, 55, 20)];
        [self.moreBtn setTitle:@"更多" forState:UIControlStateNormal];
        self.moreBtn.backgroundColor = [UIColor clearColor];
        [self.moreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.moreBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
        [self.moreView addSubview:self.moreBtn];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 54.5, sRect.size.width, 0.5)];
        lineView.backgroundColor = [UIColor bjck_colorWithHexString:@"#dcddde"];
        [self.cellView addSubview:lineView];
        
    }
    return self;
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    IMGroupUserCellMode *mode = (IMGroupUserCellMode*)self.cellMode;
    if (mode != nil && ([mode getMenuType] == KIMGroupUserCellModeMenuType_Delete || [mode getMenuType] == KIMGroupUserCellModeMenuType_DeleteAndMore)) {
        if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
            if([mode getMenuType] == KIMGroupUserCellModeMenuType_Delete)
            {
                [UIView beginAnimations:@"move" context:nil];
                [UIView setAnimationDuration:0.2];
                CGRect frame = self.cellView.frame;
                self.cellView.frame=CGRectMake(-75,frame.origin.y, frame.size.width,frame.size.height);
                [UIView commitAnimations];
                mode.ifShowMenu = YES;
            }else if ([mode getMenuType] == KIMGroupUserCellModeMenuType_DeleteAndMore)
            {
                [UIView beginAnimations:@"move" context:nil];
                [UIView setAnimationDuration:0.2];
                CGRect frame = self.cellView.frame;
                self.cellView.frame=CGRectMake(-150,frame.origin.y, frame.size.width,frame.size.height);
                [UIView commitAnimations];
                mode.ifShowMenu = YES;
            }
        }else if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
            [UIView beginAnimations:@"move" context:nil];
            [UIView setAnimationDuration:0.2];
            CGRect frame = self.cellView.frame;
            self.cellView.frame=CGRectMake(0,frame.origin.y, frame.size.width,frame.size.height);
            [UIView commitAnimations];
            mode.ifShowMenu = NO;
        }
    }
}

-(void)deleteAction
{
    if (self.cellMode != nil) {
        IMGroupUserCellMode *cellMode = (IMGroupUserCellMode*)self.cellMode;
        [cellMode deleteAction];
    }
}

-(void)moreAction
{
    if (self.cellMode != nil) {
        IMGroupUserCellMode *cellMode = (IMGroupUserCellMode*)self.cellMode;
        [cellMode moreAction];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setMyCellMode:(BaseCellMode*)cellMode
{
    [super setMyCellMode:cellMode];
    
    IMGroupUserCellMode *mode = (IMGroupUserCellMode*)self.cellMode;
    
    CGRect frame = self.cellView.frame;
    if (mode.ifShowMenu) {
        if ([mode getMenuType] == KIMGroupUserCellModeMenuType_DeleteAndMore) {
            self.cellView.frame=CGRectMake(-160,frame.origin.y, frame.size.width,frame.size.height);
        }else if([mode getMenuType] == KIMGroupUserCellModeMenuType_Delete)
        {
            self.cellView.frame=CGRectMake(-80,frame.origin.y, frame.size.width,frame.size.height);
        }
    }else
    {
        self.cellView.frame=CGRectMake(0,frame.origin.y, frame.size.width,frame.size.height);
    }
    if (mode.GroupDetailMember.onlineStatus == eUserOnlineStatus_offline)
    {
        //离线状态头像置灰
        [self.faceViewImage bjck_setImageWithURL:[NSURL URLWithString:CuteImageUrl(mode.GroupDetailMember.avatar, self.faceViewImage.current_w, self.faceViewImage.current_h)] placeholderImage:nil completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
            
            [self.faceViewImage setImage:[self grayImage:image]];
         }];
    }
    else
    {
        [self.faceViewImage bjck_setAliyunImageWithURL:[NSURL URLWithString:mode.GroupDetailMember.avatar] placeholderImage:nil];

    }
    
    CGRect sRect = [UIScreen mainScreen].bounds;
    CGFloat nameLw = sRect.size.width-(30+40+10+10+60);
    CGSize teacherNameSize = [mode.GroupDetailMember.user_name sizeWithFont:[UIFont systemFontOfSize:16.0f]];
    if (nameLw > teacherNameSize.width) {
        nameLw = teacherNameSize.width;
    }
    self.userNameL.frame = CGRectMake(15+40+10, 20, nameLw, 20);
    self.userNameL.text = mode.GroupDetailMember.user_name;
    
    if (mode.GroupDetailMember.onlineStatus == eUserOnlineStatus_offline) {
        //离线状态名称置灰
        self.userNameL.textColor = [UIColor bjck_colorWithHexString:IMCOLOT_GREY400];
    }
    else
    {
        self.userNameL.textColor = [UIColor bjck_colorWithHexString:IMCOLOT_GREY600];
    }
    
    if (mode.GroupDetailMember.is_major == 1) {
        self.userRoleL.hidden = NO;
        self.userRoleL.frame = CGRectMake(15+40+10+10+nameLw, 20, 60, 20);
        self.userRoleL.text = @"群主";
    }else if(mode.GroupDetailMember.is_admin == 1)
    {
        self.userRoleL.hidden = NO;
        self.userRoleL.frame = CGRectMake(15+40+10+10+nameLw, 20, 60, 20);
        self.userRoleL.text = @"管理员";
    }else
    {
        self.userRoleL.hidden =YES;
    }
    
}
#pragma mark - 图片灰度处理
- (UIImage *)grayImage:(UIImage *)sourceImage {
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil, width, height, 8, 0, colorSpace, kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), sourceImage.CGImage);
    UIImage *grayedImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayedImage;
}

@end

@interface IMGroupUserCellMode()

@property (strong ,nonatomic) IMSingleSelectDialog *dialog;

@end

@implementation IMGroupUserCellMode

-(instancetype)initWithGroupDetailMember:(GroupDetailMember*)member
{
    self = [super init];
    if (self) {
        self.GroupDetailMember = member;
        self.operaterIsAdmin = NO;
        self.operaterIsMajor = YES;
    }
    return self;
}

-(NSString*)getCellIdentifier
{
    return [NSString stringWithFormat:@"IMGroupUserCellMode"];
}

-(CGFloat)getCellHeight
{
    return 55.0f;
}

-(BaseModeCell*)createModeCell
{
    IMGroupUserCell *cell = [[IMGroupUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self getCellIdentifier]];
    return cell;
}

-(IMGroupUserCellModeMenuType)getMenuType
{
    User *ower = [IMEnvironment shareInstance].owner;
    
    if (ower.userId == self.GroupDetailMember.user_id && ower.userRole == self.GroupDetailMember.user_role ) {
        return KIMGroupUserCellModeMenuType_NoMenu;
    }
    
    if (self.operaterIsMajor) {
        if (self.GroupDetailMember.is_major) {
            return KIMGroupUserCellModeMenuType_NoMenu;
        }else
        {
            return KIMGroupUserCellModeMenuType_DeleteAndMore;
        }
    }else
    {
        if (self.operaterIsAdmin) {
            if (self.GroupDetailMember.is_major) {
                return KIMGroupUserCellModeMenuType_NoMenu;
            }else
            {
                if (self.GroupDetailMember.is_admin) {
                    return KIMGroupUserCellModeMenuType_NoMenu;
                }else
                {
                    return KIMGroupUserCellModeMenuType_Delete;
                }
            }
        }else
        {
            return KIMGroupUserCellModeMenuType_NoMenu;
        }
    }
}

-(void)deleteAction
{
    if (self.groupUserDelegate != nil) {
        [self.groupUserDelegate removeGroupUser:self];
    }
}

-(void)moreAction
{
    WS(weakSelf);
    self.dialog = [[IMSingleSelectDialog alloc] init];
    NSArray *array = nil;
    if (self.GroupDetailMember.is_admin) {
        array = [NSArray arrayWithObjects:@"取消该成员为管理员",@"移交群给该成员", nil];
    }else
    {
        array = [NSArray arrayWithObjects:@"设置该成员为管理员",@"移交群给该成员", nil];
    }
    [self.dialog showWithTitle:@"请选择将要进行的操作" withArray:array withSelectBlock:^(NSInteger index) {
        if (index == 0) {
            if (weakSelf.GroupDetailMember.is_admin) {
                [self.groupUserDelegate cancelGroupUserAmin:weakSelf];
            }else
            {
                [self.groupUserDelegate setGroupUserAdmin:weakSelf];
            }
        }else if (index == 1)
        {
            [self.groupUserDelegate tranferGroupUser:weakSelf];
        }
    } withCancelBlock:^{
        
    }];
}


@end
