//
//  ChatDraft.m
//  
//
//  Created by Randy on 15/7/31.
//
//

#import "BJChatDraft.h"
#import <IMEnvironment.h>

@implementation BJChatDraft

@dynamic content;
@dynamic userRole;
@dynamic updateTime;
@dynamic userId;
@dynamic ownerUserId;
@dynamic ownerUserRole;

+ (BJChatDraft *)conversationDraftForUserId:(long long)userId andUserRole:(int)userRole;
{
    NSNumber *un = [NSNumber numberWithLongLong:userId];
    NSNumber *ur = [NSNumber numberWithInt:userRole];
    
    NSPredicate *toUser = [NSPredicate predicateWithFormat:@"userId = %@ AND userRole = %@", un,ur];
    NSPredicate *curUser = [NSPredicate predicateWithFormat:@"ownerUserId = %@ AND ownerUserRole = %@", @([IMEnvironment shareInstance].owner.userId),@([IMEnvironment shareInstance].owner.userRole)];

    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[toUser,curUser]];
    BJChatDraft *ad = [BJChatDraft MR_findFirstWithPredicate:compoundPredicate];
    return ad;
}

+ (BJChatDraft *)persistNewDraftForUserId:(long long)userId andUserRole:(int)userRole content:(NSString *)cnt;
{
    BJChatDraft *ad = [BJChatDraft conversationDraftForUserId:userId andUserRole:userRole];
    if (ad){
        ad.content = cnt;
        ad.updateTime = [NSDate date];
    } else {
        
        ad = [BJChatDraft MR_createEntity];
        ad.userRole = @(userRole);
        ad.userId = @(userId);
        ad.content = cnt;
        ad.updateTime = [NSDate date];
        ad.ownerUserRole = @([IMEnvironment shareInstance].owner.userRole);
        ad.ownerUserId = @([IMEnvironment shareInstance].owner.userId);
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return ad;
}

- (void)updateContent:(NSString *)cnt
{
    self.content = cnt;
    self.updateTime = [NSDate date];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

@end
