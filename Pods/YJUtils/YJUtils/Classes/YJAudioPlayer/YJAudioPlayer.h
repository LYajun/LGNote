//
//  YJAudioPlayer.h
//  Pods-YJUtils_Example
//
//  Created by 刘亚军 on 2019/8/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol YJAudioPlayerDelegate <NSObject>

@optional
/** 音频准备就绪 */
- (void)yj_audioPlayerReadyToPlay;
/** 音频解码发生错误 */
- (void)yj_audioPlayerDecodeError;
/** 音频播放完成 */
- (void)yj_audioPlayerDidPlayComplete;
/** 音频播放失败 */
- (void)yj_audioPlayerDidPlayFailed;
/** 音频播放中断 */
- (void)yj_audioPlayerBeginInterruption;
/** 音频播放结束中断 */
- (void)yj_audioPlayerEndInterruption;
/** 音频当前播放时长、进度 */
- (void)yj_audioPlayerCurrentPlaySeconds:(NSTimeInterval)seconds progress:(CGFloat)progress;
/** 音频当前缓冲时长、进度 */
- (void)yj_audioPlayerCurrentBufferSeconds:(NSTimeInterval)seconds progress:(CGFloat)progress;
/** 需要缓冲 音频播放被中断 */
- (void)yj_audioPlayerPlaybackBufferEmpty;
/** 缓存充足 音频播放开始播放 */
- (void)yj_audioPlayerPlaybackLikelyToKeepUp;
@end

@interface YJAudioPlayer : NSObject

/** 音频路径*/
@property (nonatomic, strong) NSString *audioUrl;

/** 播放代理 */
@property (nonatomic, weak) id<YJAudioPlayerDelegate> delegate;

/** 当前播放时间 */
@property (nonatomic, assign,readonly) NSTimeInterval currentPlayTime;
/** 音频总时长 */
@property (nonatomic, assign,readonly) NSTimeInterval totalDuration;
/** 播放速率 */
@property (nonatomic, assign) CGFloat audioRate;
/** 是否正在播放 */
@property (nonatomic, assign,readonly) BOOL isPlaying;

/** 后台模式播放 */
- (void)play;
/** 混音播放 可以与其他音频应用同时播放，并受静音键控制 */
- (void)playAmbient;
/** 播放录音文件 */
- (void)playRecord;

- (void)pause;
- (void)stop;
- (void)invalidate;

- (void)seekToSecondTime:(CGFloat)time;
@end

NS_ASSUME_NONNULL_END
