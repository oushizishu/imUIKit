//
//  BJIMQuickResponseManager.m
//  BJEducation_Institution
//
//  Created by Mac_ZL on 16/11/4.
//  Copyright © 2016年 com.bjhl. All rights reserved.
//

#import "BJIMQuickResponseManager.h"
#import <BJHL-IM-iOS-SDK/NetWorkTool.h>
#import <BJHL-Network-iOS/BJHL-Network-iOS.h>



#define HOST_APIS @[@"http://dev01-hermes.genshuixue.com", @"http://beta-hermes.genshuixue.com", @"http://hermes.genshuixue.com"]
#define HOST_API HOST_APIS[[IMEnvironment shareInstance].debugMode]

#define HERMES_API_QUICKRESPONSE_ADD [NSString stringWithFormat:@"%@/hermes/addQuickResponse", HOST_API]
#define HERMES_API_QUICKRESPONSE_DELETE [NSString stringWithFormat:@"%@/hermes/deleteQuickResponse", HOST_API]
#define HERMES_API_QUICKRESPONSE_UPDATE [NSString stringWithFormat:@"%@/hermes/updateQuickResponse", HOST_API]
#define HERMES_API_QUICKRESPONSE_LIST [NSString stringWithFormat:@"%@/hermes/getQuickResponseList", HOST_API]


@implementation BJIMQuickResponseManager


+ (void)addQuickResponseWithContent:(NSString *)content
                            success:(BJCNOnSuccess)succ
                            failure:(BJCNOnFailure)failure
{
    BJCNRequestParams *requestParams = [[BJCNRequestParams alloc] initWithUrl:HERMES_API_QUICKRESPONSE_ADD method:kBJCNHttpMethod_POST];
    
    [requestParams appendPostParamValue:[IMEnvironment shareInstance].oAuthToken forKey:@"auth_token"];
    [requestParams appendPostParamValue:content forKey:@"content"];
    [requestParams appendPostParamValue:@"im_version" forKey:[[IMEnvironment shareInstance] getCurrentVersion]];
    [BJCNNetworkUtilInstance doNetworkRequest:requestParams success:succ failure:failure];
}

+ (void)deleteQuickResponseId:(NSString *)responseId
                      success:(BJCNOnSuccess)succ
                      failure:(BJCNOnFailure)failure

{
    BJCNRequestParams *requestParams = [[BJCNRequestParams alloc] initWithUrl:HERMES_API_QUICKRESPONSE_DELETE method:kBJCNHttpMethod_POST];
    
    [requestParams appendPostParamValue:[IMEnvironment shareInstance].oAuthToken forKey:@"auth_token"];
    [requestParams appendPostParamValue:responseId forKey:@"id"];
    [requestParams appendPostParamValue:@"im_version" forKey:[[IMEnvironment shareInstance] getCurrentVersion]];
    [BJCNNetworkUtilInstance doNetworkRequest:requestParams success:succ failure:failure];

}

+ (void)updateQuickResponseId:(NSString *)responseId
                      content:(NSString *)content
                      success:(BJCNOnSuccess)succ
                      failure:(BJCNOnFailure)failure

{
    BJCNRequestParams *requestParams = [[BJCNRequestParams alloc] initWithUrl:HERMES_API_QUICKRESPONSE_UPDATE method:kBJCNHttpMethod_POST];
    
    [requestParams appendPostParamValue:[IMEnvironment shareInstance].oAuthToken forKey:@"auth_token"];
    [requestParams appendPostParamValue:responseId forKey:@"id"];
    [requestParams appendPostParamValue:content forKey:@"content"];
    [requestParams appendPostParamValue:@"im_version" forKey:[[IMEnvironment shareInstance] getCurrentVersion]];
    [BJCNNetworkUtilInstance doNetworkRequest:requestParams success:succ failure:failure];
    
}

+ (void)getQuickResponseList:(BJCNOnSuccess)succ
                     failure:(BJCNOnFailure)failure
{
    BJCNRequestParams *requestParams = [[BJCNRequestParams alloc] initWithUrl:HERMES_API_QUICKRESPONSE_LIST method:kBJCNHttpMethod_POST];
    [requestParams appendPostParamValue:[IMEnvironment shareInstance].oAuthToken forKey:@"auth_token"];
    [requestParams appendPostParamValue:@"im_version" forKey:[[IMEnvironment shareInstance] getCurrentVersion]];
    [BJCNNetworkUtilInstance doNetworkRequest:requestParams success:succ failure:failure];
}
@end
