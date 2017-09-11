//
//  AVPlayerTool.h
//  音频--AVPlayer
//
//  Created by 邱荣贵 on 2017/9/11.
//  Copyright © 2017年 QIUGUI. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import <Foundation/Foundation.h>

#import "Voice.h"

@protocol KSAudioPlayerManagerDelegate <NSObject>

@optional

- (void)startPlayWithplayer:(AVPlayer *)player;
- (void)updateProgressWithPlayer:(AVPlayer *)player;
- (void)changeNewPlayItem:(AVPlayer *)player;
- (void)player:(AVPlayer *)player changeRate:(float)changeRate;
- (void)updateBufferProgress:(NSTimeInterval)progress;

@end

typedef NS_ENUM(NSInteger, KSPlayingSortType1) {
    KSPlayingSortTypeSequence1   = 0, // 顺序播放
    KSPlayingSortTypeLoop1       = 1, // 循环播放
    KSPlayingSortTypeRandom1     = 2, // 随机播放
    KSPlayingSortTypeSingleloop1 = 3, // 单曲循环
};

typedef void (^PlayingSorTypeSwitchBlock1)(KSPlayingSortType1);

@interface AVPlayerManager : NSObject

@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, assign) KSPlayingSortType1 playingSortType;
@property (nonatomic, strong) NSArray<Voice *> *voices;
@property (nonatomic, strong) Voice *currentVoice;
@property (nonatomic, assign) NSInteger currentVoiceIndex;
@property (nonatomic, weak) id<KSAudioPlayerManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *historyModels;

@property (nonatomic, copy) NSString *durationStr;
@property (nonatomic, copy) NSString *currentTimeStr;

+ (instancetype)sharedManager;

/**
 *  播放
 */
- (void)play;

/**
 *  暂停
 */
- (void)pause;

/**
 *  下一个
 */
- (void)playNext;

/**
 *  上一个
 */
- (void)playPrevious;

/**
 *  播放一个Voice
 *
 *  @param index 根据索引去播放
 */
- (void)playAnyVoiceWithIndex:(NSInteger)index;

/**
 *  设置音量
 *
 *  @param value 待设置音量
 */

- (void)setupCurrentVolume:(CGFloat)value;

/**
 *  根据进度条快进快退时间设置当前播放时间
 *
 *  @param value 待设置时间
 */
- (void)setupCurrentTimeWithSilderValue:(CGFloat)value completion:(void(^)(void))completion;

/**
 *  设置锁屏控制中心
 */
- (void)configNowPlayingCenterWithBackground:(BOOL)background;

/**
 *  切换播放模式
 *
 *  @param switchBlock 回调
 */
- (void)switchToNextPlayingSortType:(PlayingSorTypeSwitchBlock1)switchBlock;

@end
