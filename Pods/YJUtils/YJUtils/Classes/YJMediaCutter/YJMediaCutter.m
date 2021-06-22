//
//  YJMediaCutter.m
//  Pods-YJUtils_Example
//
//  Created by 刘亚军 on 2019/10/8.
//

/*
 相关知识：一个工程文件中有很多轨道，如音频轨道1，音频轨道2，音频轨道3，视频轨道1，视频轨道2等等，每个轨道里有许多素材，对于每个视频素材，它可以进行缩放、旋转等操作，素材库中的视频拖到轨道中会分为视频轨和音频轨两个轨道
 AVAsset：素材库里的素材；
 AVAssetTrack：素材的轨道；
 AVMutableComposition ：一个用来合成视频的工程文件；
 AVMutableCompositionTrack ：工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材；
 AVMutableVideoCompositionLayerInstruction：视频轨道中的一个视频，可以缩放、旋转等；
 AVMutableVideoCompositionInstruction：一个视频轨道，包含了这个轨道上的所有视频素材；
 AVMutableVideoComposition：管理所有视频轨道，可以决定最终视频的尺寸，裁剪需要在这里进行；
 AVAssetExportSession：配置渲染参数并渲染。
 */

#import "YJMediaCutter.h"
#import <AVFoundation/AVFoundation.h>

#define kFileManager [NSFileManager defaultManager]

@interface YJMediaCutter ()<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

/** 是否剪辑视频 */
@property (nonatomic,assign) BOOL isVideoCut;
/** 媒体名称 */
@property (nonatomic,copy) NSString *mediaName;
/** 媒体扩展名 */
@property (nonatomic,copy) NSString *mediaExtName;




@property (nonatomic,copy) void (^ _Nullable completionHandler) (NSError * _Nullable error);
@property (nonatomic,copy) void (^ _Nullable cutProgressHandler) (CGFloat progress);
@end
@implementation YJMediaCutter
+ (YJMediaCutter *)shareMediaCutter{
    static YJMediaCutter * macro = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        macro = [[YJMediaCutter alloc]init];
    });
    return macro;
}

#pragma mark - 视频剪辑
- (void)videoCutWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler{
    NSString *typeStr = [NSString stringWithFormat:@"video/%@",self.mediaExtName.lowercaseString];
    if (![AVURLAsset isPlayableExtendedMIMEType:typeStr]) {
        if (completionHandler) {
            completionHandler([NSError errorWithDomain:@"_YJMediaCutterErrorDamain" code:110 userInfo:@{NSLocalizedDescriptionKey:@"不支持该格式"}]);
        }
        return;
    }
    
    if ([kFileManager fileExistsAtPath:self.outPutFilePath]) {
        if (completionHandler) {
            completionHandler(nil);
        }
        return;
    }
    
    self.completionHandler = completionHandler;
    self.isVideoCut = YES;
    [self startDownloadMedia];
}
- (void)videoCutWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler cutProgressHandler:(void (^)(CGFloat))cutProgressHandler{
    self.cutProgressHandler = cutProgressHandler;
    [self videoCutWithCompletionHandler:completionHandler];
}
- (void)videoSrtCutWithSrtInfo:(NSDictionary *)srtInfo completionHandler:(void (^)(NSDictionary * _Nullable))completionHandler{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:srtInfo];
    NSMutableArray *srtArr = [dic objectForKey:@"srtList"];
    if (srtArr && srtArr.count > 0) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *srt in srtArr) {
            CGFloat beginTime = [[srt objectForKey:@"beginTime"] doubleValue];
            CGFloat endTime = [[srt objectForKey:@"endTime"] doubleValue];
            
            if (!self.isAllContain) {
                
                if (beginTime >= self.cutStartTime && endTime <= self.cutEndTime) {
                    NSMutableDictionary *srt_m = [NSMutableDictionary dictionaryWithDictionary:srt];
                    beginTime = beginTime - self.cutStartTime;
                    endTime = endTime - self.cutStartTime;
                    [srt_m setObject:@(beginTime) forKey:@"beginTime"];
                    [srt_m setObject:@(endTime) forKey:@"endTime"];
                    [arr addObject:srt_m];
                }
                
            }else{
                if ((endTime > self.cutStartTime && endTime <= self.cutEndTime) ||
                    (beginTime >= self.cutStartTime && beginTime < self.cutEndTime)) {
                    
                    NSMutableDictionary *srt_m = [NSMutableDictionary dictionaryWithDictionary:srt];
                    if (beginTime > self.cutStartTime) {
                        beginTime = beginTime - self.cutStartTime;
                    }else{
                        beginTime = 0;
                    }
                    if (endTime > self.cutEndTime) {
                        endTime = self.cutEndTime - self.cutStartTime;
                    }else{
                        endTime = endTime - self.cutStartTime;
                    }
                    [srt_m setObject:@(beginTime) forKey:@"beginTime"];
                    [srt_m setObject:@(endTime) forKey:@"endTime"];
                    [arr addObject:srt_m];
                }
                
            }
            
        }
        [dic setObject:arr forKey:@"srtList"];
    }
    completionHandler(dic);
}
- (void)startVideoCutWithPresetName:(NSString *)presetName{
    NSURL *mediaFileURL = [NSURL fileURLWithPath:self.downloadMediaPath];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    AVAsset *videoAsset = [AVAsset assetWithURL:mediaFileURL];
    //素材的视频轨
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    //素材的音频轨
    AVAssetTrack *audioAssertTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    
    if (![presets containsObject:presetName]) {
        if (self.completionHandler) {
            self.completionHandler([NSError errorWithDomain:@"_YJMediaCutterErrorDamain" code:110 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"当前设备不支持该预设:%@", presetName]}]);
        }
        return;
    }
    //视频轨道
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    //音频轨道
    AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    //在视频轨道插入一个时间段的视频
    NSTimeInterval cutStartTime = self.cutStartTime > 0 ? self.cutStartTime:0;
    NSTimeInterval duration = CMTimeGetSeconds(videoAssetTrack.timeRange.duration);
    NSTimeInterval cutEndTime = self.cutEndTime > duration ? duration:self.cutEndTime;
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(cutStartTime, videoAssetTrack.timeRange.duration.timescale), CMTimeMakeWithSeconds(cutEndTime-cutStartTime, videoAssetTrack.timeRange.duration.timescale)) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    //插入音频数据，否则没有声音
    [audioCompositionTrack insertTimeRange: CMTimeRangeMake(CMTimeMakeWithSeconds(cutStartTime, videoAssetTrack.timeRange.duration.timescale), CMTimeMakeWithSeconds(cutEndTime-cutStartTime, videoAssetTrack.timeRange.duration.timescale)) ofTrack:audioAssertTrack atTime:kCMTimeZero error:nil];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:presetName];
    exporter.outputURL = [NSURL fileURLWithPath:self.outPutFilePath];
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    NSArray *supportedTypeArray = exporter.supportedFileTypes;
    if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
        exporter.outputFileType = AVFileTypeMPEG4;
    }else{
        if (supportedTypeArray == 0) {
            if (self.completionHandler) {
                self.completionHandler([NSError errorWithDomain:@"_YJMediaCutterErrorDamain" code:110 userInfo:@{NSLocalizedDescriptionKey:@"该格式暂不支持导出"}]);
            }
            return;
        }else{
            exporter.outputFileType = [supportedTypeArray objectAtIndex:0];
        }
    }
    AVMutableVideoComposition *videoComposition = [self fixedCompositionWithAsset:composition degrees:[self degressFromVideoFileWithAsset:videoAsset]];
    if (videoComposition.renderSize.width) {
        // 修正视频转向
        exporter.videoComposition = videoComposition;
    }
    
    __weak typeof(self) weakSelf = self;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exporter.error && [presetName isEqualToString:AVAssetExportPresetMediumQuality]) {
                [weakSelf startVideoCutWithPresetName:AVAssetExportPresetLowQuality];
            }else{
                if ([kFileManager fileExistsAtPath:weakSelf.downloadMediaPath]) {
                    [kFileManager removeItemAtPath:weakSelf.downloadMediaPath error:nil];
                }
                if (weakSelf.completionHandler) {
                    weakSelf.completionHandler(exporter.error);
                }
            }
        });
    }];
}
// 获取视频角度
- (int)degressFromVideoFileWithAsset:(AVAsset *)asset {
    int degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        } else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}

// 获取优化后的视频转向信息
- (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset degrees:(int)degrees {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    if (degrees > 0) {
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
        AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        if (degrees == 90) {
            // 顺时针旋转90°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 180){
            // 顺时针旋转180°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 270){
            // 顺时针旋转270°
            translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2*3.0);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        }
        
        roateInstruction.layerInstructions = @[roateLayerInstruction];
        // 加入视频方向信息
        videoComposition.instructions = @[roateInstruction];
    }
    return videoComposition;
}

#pragma mark - 音频剪辑
- (void)audioCutWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler{
    NSString *typeStr = [NSString stringWithFormat:@"audio/%@",self.mediaExtName.lowercaseString];
    if (![AVURLAsset isPlayableExtendedMIMEType:typeStr]) {
        if (completionHandler) {
            completionHandler([NSError errorWithDomain:@"_YJMediaCutterErrorDamain" code:110 userInfo:@{NSLocalizedDescriptionKey:@"不支持该格式"}]);
        }
        return;
    }
    
    
    NSString *mediaNamePre = [self.mediaName componentsSeparatedByString:@"."].firstObject;
    _mediaName = [NSString stringWithFormat:@"%@.%@",mediaNamePre,@"m4a"];
    
    if ([kFileManager fileExistsAtPath:self.outPutFilePath]) {
        if (completionHandler) {
            completionHandler(nil);
        }
        return;
    }
    self.completionHandler = completionHandler;
    self.isVideoCut = NO;
    [self startDownloadMedia];
}
- (void)audioCutWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler cutProgressHandler:(void (^)(CGFloat))cutProgressHandler{
    self.cutProgressHandler = cutProgressHandler;
    [self audioCutWithCompletionHandler:completionHandler];
}
- (void)audioLrcCutWithLrcInfo:(NSDictionary *)lrcInfo completionHandler:(void (^)(NSDictionary * _Nullable))completionHandler{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:lrcInfo];
    NSMutableArray *srtArr = [dic objectForKey:@"srtList"];
    if (srtArr && srtArr.count > 0) {
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0 ; i < srtArr.count; i++) {
            NSDictionary *srt = srtArr[i];
            CGFloat beginTime = [[srt objectForKey:@"beginTime"] doubleValue];
            
             if (!self.isAllContain) {
                 if (i == srtArr.count-1) {
                     // beginTime >= self.cutStartTime && beginTime < self.cutEndTime && self.mediaDuration <= self.cutEndTime
                     if (beginTime >= self.cutStartTime && beginTime < self.cutEndTime) {
                         NSMutableDictionary *srt_m = [NSMutableDictionary dictionaryWithDictionary:srt];
                         beginTime = beginTime - self.cutStartTime;
                         [srt_m setObject:@(beginTime) forKey:@"beginTime"];
                         [arr addObject:srt_m];
                     }
                 }else{
                     NSDictionary *nextSrt = srtArr[i+1];
                     CGFloat endTime = [[nextSrt objectForKey:@"beginTime"] doubleValue];
                     if ((beginTime >= self.cutStartTime && beginTime < self.cutEndTime) &&
                         endTime <= self.cutEndTime) {
                         NSMutableDictionary *srt_m = [NSMutableDictionary dictionaryWithDictionary:srt];
                         beginTime = beginTime - self.cutStartTime;
                         [srt_m setObject:@(beginTime) forKey:@"beginTime"];
                         [arr addObject:srt_m];
                     }
                 }
             }else{
                 if (i == srtArr.count-1) {
                     if ((beginTime > self.cutStartTime && beginTime < self.cutEndTime) ||
                         beginTime == self.cutStartTime || beginTime == self.cutEndTime) {
                         
                         NSMutableDictionary *srt_m = [NSMutableDictionary dictionaryWithDictionary:srt];
                         if (beginTime > self.cutStartTime) {
                             beginTime = beginTime - self.cutStartTime;
                         }else{
                             beginTime = 0;
                         }
                         [srt_m setObject:@(beginTime) forKey:@"beginTime"];
                         [arr addObject:srt_m];
                     }
                 }else{
                     NSDictionary *nextSrt = srtArr[i+1];
                     CGFloat endTime = [[nextSrt objectForKey:@"beginTime"] doubleValue];
                     if ((endTime > self.cutStartTime && endTime <= self.cutEndTime) ||
                         (beginTime >= self.cutStartTime && beginTime < self.cutEndTime)) {
                         NSMutableDictionary *srt_m = [NSMutableDictionary dictionaryWithDictionary:srt];
                         if (beginTime > self.cutStartTime) {
                             beginTime = beginTime - self.cutStartTime;
                         }else{
                             beginTime = 0;
                         }
                         [srt_m setObject:@(beginTime) forKey:@"beginTime"];
                         [arr addObject:srt_m];
                     }
                 }
                 
             }
            
        }
        [dic setObject:arr forKey:@"srtList"];
    }
    completionHandler(dic);
}
- (void)startAudioCut{
    NSURL *mediaFileURL = [NSURL fileURLWithPath:self.downloadMediaPath];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    AVAsset *videoAsset = [AVAsset assetWithURL:mediaFileURL];

    //素材的音频轨
    AVAssetTrack *audioAssertTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    
    //音频轨道
    AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
   
    NSTimeInterval cutStartTime = self.cutStartTime > 0 ? self.cutStartTime:0;
    NSTimeInterval duration = CMTimeGetSeconds(audioAssertTrack.timeRange.duration);
    NSTimeInterval cutEndTime = self.cutEndTime > duration ? duration:self.cutEndTime;

    //插入音频数据，否则没有声音
    [audioCompositionTrack insertTimeRange: CMTimeRangeMake(CMTimeMakeWithSeconds(cutStartTime, audioAssertTrack.timeRange.duration.timescale), CMTimeMakeWithSeconds(cutEndTime-cutStartTime, audioAssertTrack.timeRange.duration.timescale)) ofTrack:audioAssertTrack atTime:kCMTimeZero error:nil];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    exporter.outputURL = [NSURL fileURLWithPath:self.outPutFilePath];
    exporter.outputFileType = AVFileTypeAppleM4A;
    exporter.shouldOptimizeForNetworkUse = YES;
    NSArray *supportedTypeArray = exporter.supportedFileTypes;
    if ([supportedTypeArray containsObject:AVFileTypeAppleM4A]) {
        exporter.outputFileType = AVFileTypeAppleM4A;
    }else{
        if (supportedTypeArray == 0) {
            if (self.completionHandler) {
                self.completionHandler([NSError errorWithDomain:@"_YJMediaCutterErrorDamain" code:110 userInfo:@{NSLocalizedDescriptionKey:@"该格式暂不支持导出"}]);
            }
            return;
        }else{
            exporter.outputFileType = [supportedTypeArray objectAtIndex:0];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([kFileManager fileExistsAtPath:weakSelf.downloadMediaPath]) {
                [kFileManager removeItemAtPath:weakSelf.downloadMediaPath error:nil];
            }
            if (weakSelf.completionHandler) {
                weakSelf.completionHandler(exporter.error);
            }
            
        });
    }];
}
#pragma mark - 公共方法

- (void)startDownloadMedia{
    NSString *urlStr = [self.mediaUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"identity" forHTTPHeaderField:@"Accept-Encoding"];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
}

- (void)removeAllCutFile{
    if ([kFileManager fileExistsAtPath:self.mediaDir]) {
        [kFileManager removeItemAtPath:self.mediaDir error:nil];
    }
}

- (void)setMediaUrl:(NSString *)mediaUrl{
    _mediaUrl = mediaUrl;
    if (mediaUrl && mediaUrl.length > 0) {
        NSArray *array = [mediaUrl componentsSeparatedByString:@"/"];
        _mediaName = array.lastObject;
        _mediaExtName = [_mediaName componentsSeparatedByString:@"."].lastObject;
    }else{
        _mediaName = @"";
        _mediaExtName = @"";
    }
}

#pragma mark - NSURLSessionDelegate
/** 下载完成 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    // 将下载在临时文件里的文件移至相对应的文件。
    [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:self.downloadMediaPath error:nil];
    if (self.isVideoCut) {
        [self startVideoCutWithPresetName:AVAssetExportPresetMediumQuality];
    }else{
        [self startAudioCut];
    }
}
/*
 1.当接收到下载数据的时候调用,可以在该方法中监听文件下载的进度
 该方法会被调用多次
 totalBytesWritten:已经写入到文件中的数据大小
 totalBytesExpectedToWrite:目前文件的总大小
 bytesWritten:本次下载的文件数据大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    if (self.cutProgressHandler) {
        CGFloat progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        self.cutProgressHandler(progress);
    }
}
/** 下载请求出错 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error{
    if (self.completionHandler) {
        self.completionHandler(error);
    }
}
/** 下载出错 */
- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    if (error && self.completionHandler) {
        self.completionHandler(error);
    }
}
#pragma mark - Getter
- (NSURLSession *)session{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 15;
        _session = [NSURLSession sessionWithConfiguration: config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    }
    return _session;
}
- (NSString *)mediaDir{
    NSString *libraryDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *mediaDir = [libraryDir stringByAppendingPathComponent:@"YJMediaCutter"];
    if (![kFileManager fileExistsAtPath:mediaDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:mediaDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return mediaDir;
}
- (NSString *)downloadMediaPath{
    NSString *name = [self.mediaName componentsSeparatedByString:@"."].firstObject;
    NSString *path = [self.mediaDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@_orgin.%@",self.mediaID,name,self.mediaExtName]];
    return path;
}
- (NSString *)outPutFilePath{
    NSString *outPutFilePath = [self.mediaDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@",self.mediaID,self.mediaName]];
    return outPutFilePath;
}
@end

