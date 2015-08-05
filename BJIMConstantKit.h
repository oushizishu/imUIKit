//
//  BJIMConstantKit.h
//  BJEducation_Institution
//
//  Created by Randy on 15/8/5.
//  Copyright (c) 2015年 com.bjhl. All rights reserved.
//

#ifndef BJEducation_Institution_BJIMConstantKit_h
#define BJEducation_Institution_BJIMConstantKit_h

typedef NS_ENUM (NSInteger, BJPushType){
    ePush_System = 0,
    ePush_Chat = 1,
    ePush_Asking = 2,
    ePush_Rob = 3,
};

typedef NS_ENUM (NSInteger, BJContactType)
{
    //    Contact_Visitor = -1,
    BJContact_Teacher = 0,
    BJContact_Students = 2,
    BJContact_Organization = 6,
    BJContact_KeFu = 7,
    BJContact_Admin = 1000,
    BJContact_Group = 1001,
    BJContact_Unkonwn = 1002,
};

#endif
