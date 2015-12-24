//
//  IMFileCellMode.h
//  说明:群文件操作cellMode
//  Created by wangziliang on 15/12/3.
//  Copyright © 2015年 Baijiahulian. All rights reserved.
//

#import "BaseCellMode.h"
#import <BJHL-IM-iOS-SDK/GroupDetail.h>

@protocol IMUIViewDelegate <NSObject>

- (void)userHitView:(UIView*)view;

@end

@interface IMUIView : UIView

@property(weak ,nonatomic) id<IMUIViewDelegate> delegate;

@end

@class IMFileCellMode;

@protocol IMFileCellModeDelegate <NSObject>

-(void)userPreviewGroupFile:(IMFileCellMode*)cellMode;;
-(void)userDeleteGroupFile:(IMFileCellMode*)cellMode;

@end

@interface IMProgressView : UIView

-(void)setProgressValue:(CGFloat)value;

@end

@interface IMFileUploadInfo : NSObject

@property (assign ,nonatomic) int64_t group_id;
@property (assign ,nonatomic) int64_t storage_id;
@property (strong ,nonatomic) NSString *fileName;
@property (strong ,nonatomic) NSString *filePath;
@property (strong ,nonatomic) NSString *attachment;
@property (strong ,nonatomic) NSString *info;
@property (strong ,nonatomic) NSString *bakInfo;
@property (strong ,nonatomic) NSString *createDate;

@end

typedef NS_ENUM(NSInteger, IMFileCellModeType)
{
    IMFileCellModeType_Initialization = 1,
    IMFileCellModeType_Upload = 2,
    IMFileCellModeType_UploadWait = 3,
    IMFileCellModeType_Uploading = 4,
    IMFileCellModeType_UploadRetry = 5,
    IMFileCellModeType_AddFile = 6,
    IMFileCellModeType_Download = 7,
    IMFileCellModeType_DownloadWait = 8,
    IMFileCellModeType_Downloading = 9,
    IMFileCellModeType_DownloadRetry = 10,
    IMFileCellModeType_Preview = 11,
    IMFileCellModeType_Deleteing = 12,
    IMFileCellModeType_Error = 13,
};


@interface IMFileCell : BaseModeCell

@end

@interface IMFileCellMode : BaseCellMode

@property(weak ,nonatomic)id<IMFileCellModeDelegate> fileDelegate;
@property(nonatomic)IMFileCellModeType type;
@property(strong ,nonatomic)IMFileUploadInfo *info;
@property(strong ,nonatomic)GroupFile *groupFile;
@property(assign, nonatomic)CGFloat progress;

@property(nonatomic)BOOL ifShowMenu;

- (instancetype)initWithFileUploadInfo:(IMFileUploadInfo*)info;
- (instancetype)initWithGroupFile:(GroupFile*)groupFile;

- (void)userCilckOperationBtn;
- (void)userCilckDeleteBtn;

-(void)setModeType:(IMFileCellModeType)modeType;
-(IMFileCellModeType)getModeType;

-(BOOL)ifCanEidtmenu;

@end
