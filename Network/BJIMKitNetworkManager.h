//
//  BJIMKitNetworkManager.h
//  BJEducation
//
//  Created by Mac_ZL on 16/12/2.
//  Copyright © 2016年 com.bjhl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BJIMKitNetworkManager : NSObject

#pragma mark - 快捷回复
/**
 *  @author LiangZhao, 16-11-04 16:11:47
 *
 *  添加一条快捷回复
 *
 *  @param content 快捷回复内容
 *  @param succ    成功回调
 *  @param failure 失败回调
 */
+ (void)addQuickResponseWithContent:(NSString *)content
                            success:(BJCNOnSuccess)succ
                            failure:(BJCNOnFailure)failure;


/**
 *  @author LiangZhao, 16-11-04 16:11:35
 *
 *  删除一条快捷回复
 *
 *  @param responseId 快捷回复ID
 *  @param succ       成功回调
 *  @param failure    失败回调
 */
+ (void)deleteQuickResponseId:(NSString *)responseId
                      success:(BJCNOnSuccess)succ
                      failure:(BJCNOnFailure)failure;
/**
 *  @author LiangZhao, 16-11-04 16:11:00
 *
 *  修改一条快捷回复
 *
 *  @param responseId 快捷回复ID
 *  @param content    快捷回复的内容
 *  @param succ       成功回调
 *  @param failure    失败回调
 */
+ (void)updateQuickResponseId:(NSString *)responseId
                      content:(NSString *)content
                      success:(BJCNOnSuccess)succ
                      failure:(BJCNOnFailure)failure;

/**
 *  @author LiangZhao, 16-11-04 16:11:40
 *
 *  获取快捷回复列表
 *
 *  @param succ    成功回调
 *  @param failure 失败回调
 */
+ (void)getQuickResponseList:(BJCNOnSuccess)succ
                     failure:(BJCNOnFailure)failure;

#pragma mark - 备注详情

/**
 *  @author LiangZhao, 16-12-02 16:11:40
 *
 *  设置备注详情
 *  @param userNumber IM用户ID
 *  @param userRole   用户角色
 *  @param succ    成功回调
 *  @param failure 失败回调
 */
+ (void)setRemarkDescWithUserNumber:(NSString *)userNumber
                           userRole:(IMUserRole)userRole
                         remarkDesc:(NSString *)remarkDesc
                            success:(BJCNOnSuccess)succ
                            failure:(BJCNOnFailure)failure;

/**
 *  @author LiangZhao, 16-12-02 16:11:40
 *
 *  获取备注详情
 *  @param userNumber IM用户ID
 *  @param userRole   用户角色
 *  @param succ    成功回调
 *  @param failure 失败回调
 */
+ (void)getRemarkDescWithUserNumber:(NSString *)userNumber
                           userRole:(IMUserRole)userRole
                            success:(BJCNOnSuccess)succ
                            failure:(BJCNOnFailure)failure;

@end
