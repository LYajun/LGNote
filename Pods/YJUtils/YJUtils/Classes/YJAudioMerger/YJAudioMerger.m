//
//  YJAudioMerger.m
//  Pods-YJUtils_Example
//
//  Created by 刘亚军 on 2019/8/25.
//

#import "YJAudioMerger.h"
#import <AVFoundation/AVFoundation.h>

#define kFileManager [NSFileManager defaultManager]
#define kAudioMergeName @"merge.m4a"

@interface YJAudioMerger ()

@end
@implementation YJAudioMerger

+ (YJAudioMerger *)shareAudioMerger{
    static YJAudioMerger * macro = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        macro = [[YJAudioMerger alloc]init];
    });
    return macro;
}

- (void)mergeAudioWithStartPath:(NSString *)startPath endPath:(NSString *)endPath{
    [self mergeAudioWithStartPath:startPath endPath:endPath completion:nil];
}
- (void)mergeAudioWithStartPath:(NSString *)startPath endPath:(NSString *)endPath completion:(void (^ _Nullable)(BOOL))completion{
    
    NSString *audioPath1 = startPath;
    NSString *audioPath2 = endPath;
    
    AVURLAsset *audioAsset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath1]];
    AVURLAsset *audioAsset2 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath2]];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    // 音频通道
    AVMutableCompositionTrack *audioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    AVMutableCompositionTrack *audioTrack2 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    
    // 音频采集通道
    AVAssetTrack *audioAssetTrack1 = [[audioAsset1 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    AVAssetTrack *audioAssetTrack2 = [[audioAsset2 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    
    // 音频合并 - 插入音轨文件
    [audioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset1.duration) ofTrack:audioAssetTrack1 atTime:kCMTimeZero error:nil];
    // `startTime`参数要设置为第一段音频的时长，即`audioAsset1.duration`, 表示将第二段音频插入到第一段音频的尾部。
    [audioTrack2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset2.duration) ofTrack:audioAssetTrack2 atTime:audioAsset1.duration error:nil];
    
    
    [self mergeAudioWithComposition:composition completion:completion];
}

- (void)mergeMoreAudioWithPaths:(NSArray *)paths{
    [self mergeMoreAudioWithPaths:paths completion:nil];
}

- (void)mergeMoreAudioWithPaths:(NSArray *)paths completion:(void (^)(BOOL))completion{
    AVMutableComposition *composition = [AVMutableComposition composition];
    CMTime lastAudioduration = kCMTimeZero;
    for (NSString *path in paths) {
         AVURLAsset *audioAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
         AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
        AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        
        NSTimeInterval lastTime = CMTimeGetSeconds(lastAudioduration);
        
        if (lastTime > 0) {
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:audioAssetTrack atTime:lastAudioduration error:nil];
        }else{
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
        }
        
        lastAudioduration = CMTimeMakeWithSeconds(CMTimeGetSeconds(audioAsset.duration) + lastTime, audioAsset.duration.timescale);
    }
    
    [self mergeAudioWithComposition:composition completion:completion];
}


- (void)mergeAudioWithComposition:(AVMutableComposition *)composition completion:(void (^ _Nullable)(BOOL))completion{
    // 合并后的文件导出 - `presetName`要和之后的`session.outputFileType`相对应。
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    NSString *outPutFilePath = [[self.outPutFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:kAudioMergeName];
    
    if ([kFileManager fileExistsAtPath:outPutFilePath]) {
        [kFileManager removeItemAtPath:outPutFilePath error:nil];
    }
    
    // 查看当前session支持的fileType类型
    NSLog(@"---%@",[session supportedFileTypes]);
    session.outputURL = [NSURL fileURLWithPath:outPutFilePath];
    session.outputFileType = AVFileTypeAppleM4A; //与上述的`present`相对应
    session.shouldOptimizeForNetworkUse = YES;   //优化网络
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (session.status == AVAssetExportSessionStatusCompleted) {
                if (completion) {
                    completion(YES);
                }
            } else {
                if (completion) {
                    completion(NO);
                }
            }
        });
    }];
}

- (NSString *)outPutFilePath{
    if (!_outPutFilePath) {
        _outPutFilePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        NSString *folderName = [_outPutFilePath stringByAppendingPathComponent:@"YJAudioMerger"];
        BOOL isCreateSuccess = [kFileManager createDirectoryAtPath:folderName withIntermediateDirectories:YES attributes:nil error:nil];
        if (isCreateSuccess) _outPutFilePath = [folderName stringByAppendingPathComponent:kAudioMergeName];
    }
    return _outPutFilePath;
}
@end
