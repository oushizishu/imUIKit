//
//  LocalImageCache.m
//  Pods
//
//  Created by bjhl on 15/8/12.
//
//

#import "LocalImageCache.h"
#import <CommonCrypto/CommonHMAC.h>
#include "sys/stat.h"
#import "SDWebImageCompat.h"

@implementation LoadLocalImageOperation

-(void)main
{
    NSArray *spArray = [[self.fileUrl relativePath] componentsSeparatedByString:@"/"];
    
    NSMutableString *muStr = [[NSMutableString alloc] initWithCapacity:100];
    
    NSUInteger count = [spArray count];
    
    for (int i=0;  i<count; i++) {
        NSString *spStr = spArray[i];
        if ([spStr length]>0) {
            [muStr appendString:@"/"];
            [muStr appendString:spStr];
        }
        if ([spStr isEqualToString:@"Application"]) {
            i++;
        }
    }
    
    NSString *fileKey = [NSString stringWithFormat:@"%@/%f/%f",muStr,self.size.width,self.size.height];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@.jpg",[self getDocumnetsDirectory],LocalImageCacheFloder,[self getStringWithStringByMD5:fileKey]];
    NSString *fileFloder = [NSString stringWithFormat:@"%@/%@",[self getDocumnetsDirectory],LocalImageCacheFloder];
    
    if (![self ifExistDircory:fileFloder]) {
        [self createDirectory:fileFloder];
    }
    
    NSLog(@"main self.fileurl = %@",self.fileUrl);
    
    UIImage *image = nil;
    
    if ([self ifExistFile:filePath]) {
        image = [UIImage imageWithContentsOfFile:filePath];
    }else
    {
        image = [self getNewImage:[self.fileUrl relativePath] withSize:self.size];
        
        if (![self ifExistDircory:fileFloder]) {
            [self createDirectory:fileFloder];
        }
        
        NSData *date = UIImageJPEGRepresentation(image, 1.0f);
        [date writeToFile:filePath atomically:YES];
    }
    
    //[self performSelectorOnMainThread:@selector(setImageOnMain:) withObject:image waitUntilDone:YES];
    
    dispatch_main_sync_safe(^{
        self.imageView.image = image;
    });
    
}

-(void)setImageOnMain:(UIImage*)image
{
    self.imageView.image = image;
}

-(NSString*)getDocumnetsDirectory
{
    NSArray *pathA = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathA objectAtIndex:0];
    return path;
}

+ (BOOL)ifExistDircory:(NSString*)path
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    BOOL ret;
    return [fileManger fileExistsAtPath:path isDirectory:&ret]&&ret;
}

-(BOOL)ifExistFile:(NSString*)path
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    BOOL ret;
    return [fileManger fileExistsAtPath:path isDirectory:&ret]&&!ret;
}

-(BOOL)ifExistDircory:(NSString*)path
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    BOOL ret;
    return [fileManger fileExistsAtPath:path isDirectory:&ret]&&ret;
}

-(BOOL)createDirectory:(NSString*)path
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    return [fileManger createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

-(NSString*)getStringWithStringByMD5:(NSString*)str
{
    const char* cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH] = {
        0,
    };
    CC_MD5(cStr, strlen(cStr), result);
    
    
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

-(UIImage*)getNewImage:(NSString*)filePath withSize:(CGSize)size
{
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    UIGraphicsBeginImageContext(CGSizeMake(size.width*3, size.height*3));
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,size.width*3,size.height*3)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end

@implementation LocalImageCache

+ (instancetype)sharedInstance
{
    static LocalImageCache *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[super alloc] init];
    });
    return _sharedInstance;
}

-(void)setLocalImage:(NSURL*)url withSize:(CGSize)size withImageView:(UIImageView*)imageView
{
    //[self.operationQ cancelAllOperations];
    LoadLocalImageOperation *operation = [[LoadLocalImageOperation alloc] init];
    operation.fileUrl = url;
    operation.size = size;
    operation.imageView = imageView;
    
    [self.operationQ addOperation:operation];
}

-(NSOperationQueue*)operationQ
{
    if (_operationQ == nil) {
        _operationQ = [[NSOperationQueue alloc] init];
    }
    return _operationQ;
}

@end
