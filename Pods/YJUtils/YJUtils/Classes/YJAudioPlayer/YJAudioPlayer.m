//
//  YJAudioPlayer.m
//  Pods-YJUtils_Example
//
//  Created by 刘亚军 on 2019/8/13.
//

#import "YJAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>


#define IsStrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@""]))

static NSString * const kStatus                   = @"status";
static NSString * const kLoadedTimeRanges         = @"loadedTimeRanges";
static NSString * const kPlaybackBufferEmpty      = @"playbackBufferEmpty";
static NSString * const kPlaybackLikelyToKeepUp   = @"playbackLikelyToKeepUp";


@interface YJAudioPlayer ()
@property (nonatomic,strong) AVPlayer *audioPlayer;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isSeekTime;
@end
@implementation YJAudioPlayer
- (instancetype)init{
    if (self = [super init]) {
        [self configure];
    }
    return self;
}
- (void)dealloc{
    [self invalidate];
}
- (void)configure{
    _audioRate = 1.0;
    
}

#pragma mark - Public

- (void)play {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    [session setActive:YES error:nil];
    [self playPlayback];
}
- (void)playAmbient{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
    [session setActive:YES error:nil];
    [self playPlayback];
}
- (void)playRecord{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    [session setActive:YES error:nil];
    [self playPlayback];
}
- (void)playPlayback{
    if (@available(iOS 10.0, *)) {
        [self.audioPlayer playImmediatelyAtRate:self.audioRate];
    } else {
        // Fallback on earlier versions
        [self.audioPlayer play];
        self.audioPlayer.rate = self.audioRate;
    }
    
    self.isPlaying = YES;
}
- (void)pause {
    [self.audioPlayer pause];
    self.isPlaying = NO;
}

- (void)stop {
    [self.audioPlayer seekToTime:kCMTimeZero];
    [self pause];
}

- (void)invalidate {
    if (self.isPlaying || self.audioPlayer.rate > 0) [self stop];
    
    [self removeNotification];
    [self removeObserver:_audioPlayer.currentItem];
    
    _audioPlayer = nil;
}
- (void)seekToSecondTime:(CGFloat)time{
    int32_t timeScale = self.audioPlayer.currentItem.asset.duration.timescale;
    CMTime cmTime = CMTimeMakeWithSeconds(time, timeScale);
    __weak typeof(self) weakSelf = self;
    [self.audioPlayer seekToTime:cmTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            weakSelf.isSeekTime = YES;
        }
    }];
}
#pragma mark - Private
+ (NSString *)deleteURLDoubleSlashWithUrlStr:(NSString *)urlStr{
    if (urlStr && urlStr.length > 0){
        urlStr = [urlStr stringByRemovingPercentEncoding];
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    }
    if (urlStr && urlStr.length > 0 && [urlStr containsString:@"://"]) {
        NSArray *urlArr = [urlStr componentsSeparatedByString:@"://"];
       NSString *lastStr = [urlArr.lastObject stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
       while ([lastStr containsString:@"//"]) {
           lastStr = [lastStr stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
       }
       urlStr = [NSString stringWithFormat:@"%@://%@",urlArr.firstObject,lastStr];
    }
    return urlStr;
}
- (void)prepareToPlay {
    [self invalidate];
    NSURL *url = nil;
    if ([self.audioUrl hasPrefix:@"http"]) {
        url = [NSURL URLWithString:[self.audioUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    }else{
        url = [NSURL fileURLWithPath:self.audioUrl];
    }
    
    AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:url];
    currentItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmTimeDomain;
    [self.audioPlayer replaceCurrentItemWithPlayerItem:currentItem];
    
    if (@available(iOS 10.0, *)) {
        // 针对播放网络音频很慢，需要等几秒的问题
        self.audioPlayer.automaticallyWaitsToMinimizeStalling = NO;
    }
    
    [self addNotification];
    [self addObserverWithPlayerItem:currentItem];
}

#pragma mark - 通知
- (void)addNotification {
    /** 播放完成 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    /** 播放失败 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayDidFailed:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    /** 声音被打断的通知（电话打来） */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    //耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    /** 进入后台 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    /** 返回前台 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

/** 播放完成 */
- (void)audioPlayDidEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = (AVPlayerItem *)notification.object;
    NSString *urlStr =  [(AVURLAsset *)playerItem.asset URL].absoluteString;
    NSString *currentUrlStr =  [(AVURLAsset *)self.audioPlayer.currentItem.asset URL].absoluteString;
    if (!IsStrEmpty(urlStr) && !IsStrEmpty(currentUrlStr) && ![urlStr isEqualToString:currentUrlStr]) {
        return;
    }
    
    [self stop];
    if (self.delegate && [self.delegate respondsToSelector:@selector(yj_audioPlayerDidPlayComplete)]) {
        [self.delegate yj_audioPlayerDidPlayComplete];
    }
}

/** 播放失败 */
- (void)audioPlayDidFailed:(NSNotification *)notification {
    [self stop];
    if (self.delegate && [self.delegate respondsToSelector:@selector(yj_audioPlayerDidPlayFailed)]) {
        [self.delegate yj_audioPlayerDidPlayFailed];
    }
}

//中断事件
- (void)handleInterruption:(NSNotification *)notification{
    NSDictionary *info = notification.userInfo;
    //一个中断状态类型
    AVAudioSessionInterruptionType type =[info[AVAudioSessionInterruptionTypeKey] integerValue];
    //判断开始中断还是中断已经结束
    if (type == AVAudioSessionInterruptionTypeBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(yj_audioPlayerBeginInterruption)]) {
            [self.delegate yj_audioPlayerBeginInterruption];
        }
    }else {
        //如果中断结束会附带一个KEY值，表明是否应该恢复音频
        AVAudioSessionInterruptionOptions options =[info[AVAudioSessionInterruptionOptionKey] integerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(yj_audioPlayerEndInterruption)]) {
                [self.delegate yj_audioPlayerEndInterruption];
            }
        }
    }
}

//耳机插入、拔出事件
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
            //判断为耳机接口
            AVAudioSessionRouteDescription *previousRoute =interuptionDict[AVAudioSessionRouteChangePreviousRouteKey];
            AVAudioSessionPortDescription *previousOutput =previousRoute.outputs[0];
            NSString *portType =previousOutput.portType;
            if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
                // 拔掉耳机继续播放
                if (self.isPlaying) [self playPlayback];
            }
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            break;
    }
}

- (void)willResignActive:(NSNotification*)notification {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yj_audioPlayerBeginInterruption)]) {
        [self.delegate yj_audioPlayerBeginInterruption];
    }
}

- (void)didBecomeActive:(NSNotification*)notification {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yj_audioPlayerEndInterruption)]) {
        [self.delegate yj_audioPlayerEndInterruption];
    }
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - KVO
- (void)addObserverWithPlayerItem:(AVPlayerItem *)playerItem {
    /** 监听AVPlayerItem状态 */
    [playerItem addObserver:self forKeyPath:kStatus options:NSKeyValueObservingOptionNew context:nil];
    /** loadedTimeRanges状态 */
    [playerItem addObserver:self forKeyPath:kLoadedTimeRanges options:NSKeyValueObservingOptionNew context:nil];
    /** 缓冲区空了，需要等待数据 */
    [playerItem addObserver:self forKeyPath:kPlaybackBufferEmpty options:NSKeyValueObservingOptionNew context:nil];
    /** playbackLikelyToKeepUp状态 */
    [playerItem addObserver:self forKeyPath:kPlaybackLikelyToKeepUp options:NSKeyValueObservingOptionNew context:nil];
    
    /** 监听播放进度 */
    __weak typeof(self)weakSelf = self;
    _timeObserver = [_audioPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:NULL usingBlock:^(CMTime time) {
        if (weakSelf.isSeekTime) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [weakSelf handleTimeObserver];
                weakSelf.isSeekTime = NO;
            });
        }else{
            [weakSelf handleTimeObserver];
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kStatus]) {
        [self handleStatusObserver:object];
    } else if ([keyPath isEqualToString:kLoadedTimeRanges]) {
        [self handleLoadedTimeRangesObserver:object];
    } else if ([keyPath isEqualToString:kPlaybackBufferEmpty]) {
        //缓冲区空了，所需做的处理操作
        if (self.delegate && [self.delegate respondsToSelector:@selector(yj_audioPlayerPlaybackBufferEmpty)]) {
            [self.delegate yj_audioPlayerPlaybackBufferEmpty];
        }
    } else if ([keyPath isEqualToString:kPlaybackLikelyToKeepUp]) {
        //由于 AVPlayer 缓存不足就会自动暂停,所以缓存充足了需要手动播放,才能继续播放
        if (_isPlaying) [self playPlayback];
        if (self.delegate && [self.delegate respondsToSelector:@selector(yj_audioPlayerPlaybackLikelyToKeepUp)]) {
            [self.delegate yj_audioPlayerPlaybackLikelyToKeepUp];
        }
    }
}
- (void)handleStatusObserver:(AVPlayerItem *)playerItem {
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) { //准备就绪
        if (self.delegate && [self.delegate respondsToSelector:@selector(yj_audioPlayerReadyToPlay)]) {
            [self.delegate yj_audioPlayerReadyToPlay];
        }
        //推荐将音视频播放放在这里
        if (_isPlaying) [self playPlayback];
    } else {
        [self invalidate];
        if (self.delegate && [self.delegate respondsToSelector:@selector(yj_audioPlayerDecodeError)]) {
            [self.delegate yj_audioPlayerDecodeError];
        }
    }
}
-  (void)handleLoadedTimeRangesObserver:(AVPlayerItem *)playerItem{
    NSArray *array = playerItem.loadedTimeRanges;
    CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval currentBufferSeconds = startSeconds + durationSeconds;//缓冲总长度
    CGFloat bufferProgress = currentBufferSeconds / CMTimeGetSeconds(playerItem.duration);
    if (self.delegate && [self.delegate respondsToSelector:@selector(yj_audioPlayerCurrentBufferSeconds:progress:)]) {
        [self.delegate yj_audioPlayerCurrentBufferSeconds:currentBufferSeconds progress:bufferProgress];
    }
}
- (void)handleTimeObserver{
    CGFloat totalSeconds = CMTimeGetSeconds(_audioPlayer.currentItem.duration);
    // 计算当前在第几秒
    CGFloat currentPlaySeconds = CMTimeGetSeconds(_audioPlayer.currentTime);
    //进度 当前时间/总时间
    CGFloat currentPlayprogress = currentPlaySeconds / totalSeconds;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(yj_audioPlayerCurrentPlaySeconds:progress:)]) {
        [self.delegate yj_audioPlayerCurrentPlaySeconds:currentPlaySeconds progress:currentPlayprogress];
    }
}

- (void)removeObserver:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:kStatus];
    [playerItem removeObserver:self forKeyPath:kLoadedTimeRanges];
    [playerItem removeObserver:self forKeyPath:kPlaybackBufferEmpty];
    [playerItem removeObserver:self forKeyPath:kPlaybackLikelyToKeepUp];
    [playerItem cancelPendingSeeks];
    [playerItem.asset cancelLoading];
    
    [_audioPlayer removeTimeObserver:_timeObserver];
    _timeObserver = nil;
}
#pragma mark - Setter & Getter

- (void)setAudioUrl:(NSString *)audioUrl{
    audioUrl = [YJAudioPlayer deleteURLDoubleSlashWithUrlStr:audioUrl];
    _audioUrl = audioUrl;
    if (!IsStrEmpty(audioUrl)) {
        [self prepareToPlay];
    }
}

- (NSTimeInterval)currentPlayTime {
    return CMTimeGetSeconds(self.audioPlayer.currentTime);
}

- (NSTimeInterval)totalDuration {
    return CMTimeGetSeconds(self.audioPlayer.currentItem.duration);
}
- (AVPlayer *)audioPlayer{
    if (!_audioPlayer) {
        _audioPlayer = [[AVPlayer alloc] init];
    }
    return _audioPlayer;
}
@end
