//
//  ChatDraft.h
//  
//
//  Created by Randy on 15/7/31.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
//#import <CoreData+MagicalRecord.h>

#import <MagicalRecord/MagicalRecord.h>

@interface BJChatDraft : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * userRole;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * ownerUserRole;
@property (nonatomic, retain) NSNumber * ownerUserId;

+ (BJChatDraft *)conversationDraftForUserId:(long long)userId andUserRole:(int)userRole;

+ (BJChatDraft *)persistNewDraftForUserId:(long long)userId andUserRole:(int)userRole content:(NSString *)cnt;

- (void)updateContent:(NSString *)cnt;

@end
