//
//  AVPlayerTool.m
//  音频--AVPlayer
//
//  Created by 邱荣贵 on 2017/9/11.
//  Copyright © 2017年 QIUGUI. All rights reserved.
//



#import "AVPlayerManager.h"

@interface AVPlayerManager()


/** <#class#>*/
@property(nonatomic,strong) AVPlayer  *player;

/** <#class#>*/
@property(nonatomic,strong) id  timeObserver;


@end

@implementation AVPlayerManager


- (void)dealloc {
    [self p_currentItemRemoveObserver];
    [self p_playerRemoveObserver];
}
+ (instancetype)sharedManager {
    static AVPlayerManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
//        _playingSortType = [GVUserDefaults standardUserDefaults].playingSortType;
//        
//        _historyModels = @[].mutableCopy;
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configLockScreenPlay) name:NSExtensionHostDidEnterBackgroundNotification object:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCurrentPlayingTime) name:UIApplicationWillTerminateNotification object:nil];
        
        [self p_playerAddObserver];
    }
    return self;
}

- (void)play {
    
    if (self.player == nil) {
        return;
    }
    if (self.player.currentItem == nil) {
        return;
    }
    if (self.player.rate) {
        return;
    } else {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            [self.player play];
        }
    }
 }

- (void)pause {
    
    if (self.player == nil) {
        return;
    }
    if (self.player.currentItem == nil) {
        return;
    }
    if (!self.player.rate) {
        return;
    } else {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            [self.player pause];
        }
    }
}

- (void)playNext {

    // 播放到最后一个自动播放第一个
    NSInteger index = self.currentVoiceIndex;
    if (++index >= [self.voices count]) {
        self.currentVoiceIndex = 0;
    } else {
        self.currentVoiceIndex = index;
    }
    Voice *voice = self.voices[self.currentVoiceIndex];
    if (voice) {
        self.currentVoice = voice;
    }
    
}

- (void)playPrevious {
    
    // 播放到第一个后自动跳最后一个
    NSInteger index = self.currentVoiceIndex;
    if (--index < 0) {
        self.currentVoiceIndex = [self.voices count] - 1;
    } else {
        self.currentVoiceIndex = index;
    }
    Voice *voice = self.voices[self.currentVoiceIndex];
    if (voice) {
        self.currentVoice = voice;
    }
}

- (void)playAnyVoiceWithIndex:(NSInteger)index {
    
    if (!self.voices || self.voices.count == 0) {
        return;
    }
    Voice *voice = nil;
    if (self.voices.count > index) {
        voice = self.voices[index];
    } else {
        voice = nil;
    }
    if (!voice) {
        return;
    }
    self.currentVoiceIndex = index;
    self.currentVoice = voice;
}

- (void)setupCurrentVolume:(CGFloat)value {
    [self.player setVolume:value];
}

- (void)setupCurrentTimeWithSilderValue:(CGFloat)value completion:(void (^)(void))completion {
    
    CGFloat duration = CMTimeGetSeconds(self.player.currentItem.duration);
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        CMTime seekTime = CMTimeMake(value, 1);
        [self.player seekToTime:seekTime completionHandler:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    }
}

- (void)switchToNextPlayingSortType:(PlayingSorTypeSwitchBlock1)switchBlock {
    
    switch (self.playingSortType) {
        case KSPlayingSortTypeSequence1:
            self.playingSortType = KSPlayingSortTypeLoop1;
            break;
        case KSPlayingSortTypeLoop1:
            self.playingSortType = KSPlayingSortTypeSingleloop1;
            break;
        case KSPlayingSortTypeSingleloop1:
            self.playingSortType = KSPlayingSortTypeSequence1;
            break;
        default:
            self.playingSortType = KSPlayingSortTypeLoop1;
            break;
    }
    
    if (switchBlock) {
        switchBlock(self.playingSortType);
    }
    
    // 保存播放模式
//    [GVUserDefaults standardUserDefaults].playingSortType = self.playingSortType;
}

- (void)p_saveHistory {
//    //保存我听过的历史
//    jy_dispatch_async_on_global_queue(^{
//        if (IS_ARR_EMPTY(self.historyModels) == NO) {
//            //删除多个
//            NSMutableArray *tempMuArr = [NSMutableArray array];
//            for (StoryModel *model in self.historyModels) {
//                
//                if ([self.currentVoice.storyModel.storyid isEqualToString:model.storyid]) {
//                    [tempMuArr addObject:model];
//                }
//            }
//            [self.historyModels removeObjectsInArray:tempMuArr];
//        }
//        [self.historyModels addObject:self.currentVoice.storyModel];
//    });
}


//播放音频的方法(下面会在控制器调用)
- (void)p_musicPlayerWithURL:(NSURL *)playerItemURL{
    // 移除监听
    [self p_currentItemRemoveObserver];
    // 创建要播放的资源
    AVPlayerItem *playerItem = [[AVPlayerItem alloc]initWithURL:playerItemURL];
    // 播放当前资源
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    // 添加观察者
    [self p_currentItemAddObserver];
}

- (void)p_playerAddObserver {
    
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
    [self.player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}

- (void)p_playerRemoveObserver {
    
    [self.player removeObserver:self forKeyPath:@"rate"];
    [self.player removeObserver:self forKeyPath:@"currentItem"];
}

- (void)p_currentItemAddObserver {
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
    
    //监控缓冲加载情况属性
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
    //监控播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    __weak typeof(self) weakSelf = self;
    //监控时间进度
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        NSLog(@"%@---%@",[weakSelf currentTimeStr],[weakSelf durationStr]);
    }];

}

- (void)p_currentItemRemoveObserver {
    
    [self.player.currentItem removeObserver:self  forKeyPath:@"status"];
    
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [self.player removeTimeObserver:self.timeObserver];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[@"new"] integerValue];
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                // 开始播放
                [self play];
                // 保存我听过的
//                [self p_saveHistory];
//                // 代理回调，开始初始化状态
//                if (self.delegate && [self.delegate respondsToSelector:@selector(startPlayWithplayer:)]) {
//                    [self.delegate startPlayWithplayer:self.player];
//                }
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                NSLog(@"加载失败");
            }
                break;
            case AVPlayerItemStatusUnknown:
            {
                NSLog(@"未知资源");
            }
                break;
            default:
                break;
        }
    } else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        //本次缓冲时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        //缓冲总长度
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        NSLog(@"共缓冲：%.2f",totalBuffer);
//        if (self.delegate && [self.delegate respondsToSelector:@selector(updateBufferProgress:)]) {
//            [self.delegate updateBufferProgress:totalBuffer];
//        }
        
    } else if ([keyPath isEqualToString:@"rate"]) {
        float rate = self.player.rate;
        NSLog(@"%f---rate",rate);
//        if (self.delegate && [self.delegate respondsToSelector:@selector(player:changeRate:)]) {
//            [self.delegate player:self.player changeRate:rate];
//        }
    } else if ([keyPath isEqualToString:@"currentItem"]) {
        NSLog(@"新的currentItem");
//        if (self.delegate && [self.delegate respondsToSelector:@selector(changeNewPlayItem:)]) {
//            [self.delegate changeNewPlayItem:self.player];
//        }
    }
}

- (void)playbackFinished:(NSNotification *)notifi {
    NSLog(@"播放完成");
//    // 需要自动播放下一首
    if (self.playingSortType == KSPlayingSortTypeSequence1) {
        // 播放列表中的最后一个故事
        if (self.currentVoiceIndex == self.voices.count-1) {
            [self pause];
            [self playAnyVoiceWithIndex:0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self pause];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kKSPlayAlreadyStopNotification" object:nil userInfo:nil];
            });
        } else {
            [self playNext];
        }
    } else if (self.playingSortType == KSPlayingSortTypeSingleloop1) {
        [self playAnyVoiceWithIndex:self.currentVoiceIndex];
    } else {
        [self playNext];
    }
}

#pragma mark  Now Playing Center
- (void)configLockScreenPlay {
    // 更新歌曲播放信息，锁屏页面
    [[AVPlayerManager sharedManager] configNowPlayingCenterWithBackground:YES];
}

- (void)saveCurrentPlayingTime {
    
#pragma mark 统计
//    if (self.currentVoice.progress != 0) {
//        NSString *paramStr = [NSString stringWithFormat:@"%lld", (unsigned long long)self.currentVoice.progress];
//        if (![paramStr isEqualToString:@"0"] && !IS_STR_EMPTY(self.currentVoice.storyModel.storyid)) {
//            ks_analytics(k_global_operation_page, k_global_operation_event_playtime, paramStr, self.currentVoice.storyModel.storyid);
//        }
//    }
}

#pragma mark - setter

- (void)setPlayingSortType:(KSPlayingSortType1)playingSortType {
    _playingSortType = playingSortType;
    // 为了调整切换播放模式时，上一曲和下一曲的按钮禁用问题
    self.currentVoiceIndex = self.currentVoiceIndex;
}

- (void)setCurrentVoice:(Voice *)currentVoice {
    @synchronized (self) {
        if (self.player.rate == 0) {
        } else  {
            // 1、同一个链接，认为是同一个故事
            if ([_currentVoice.audioFileURL.absoluteString isEqualToString:currentVoice.audioFileURL.absoluteString]) {
                // 1.1、在播放列表中，同一个index直接返回
                if (_currentVoice.index == currentVoice.index) {
                    return;
                } else {
                    // 1.2、在播放列表中，不同的索引，切换播放
                }
            } else {
                // 2、不同链接，不同故事，切换播放
            }
        }
        
#pragma mark 统计
//        if (_currentVoice.progress != 0) {
//            NSString *paramStr = [NSString stringWithFormat:@"%lld", (unsigned long long)_currentVoice.progress];
//            if (![paramStr isEqualToString:@"0"] && !IS_STR_EMPTY(_currentVoice.storyModel.storyid)) {
//                ks_analytics(k_global_operation_page, k_global_operation_event_playtime, paramStr, _currentVoice.storyModel.storyid);
//            }
//        }
        
        _currentVoice = currentVoice;
        
        [self pause];
        
        [self p_musicPlayerWithURL:_currentVoice.audioFileURL];
    }
}

#pragma mark - getter

- (AVPlayer *)player {
    if (_player == nil) {
        _player = [[AVPlayer alloc] init];
        _player.volume = .2; // 默认最大音量
    }
    return _player;
}

- (NSString *)currentTimeStr {
    //当前的播放进度
    NSTimeInterval current = CMTimeGetSeconds(self.player.currentItem.currentTime);
    return [self timeFormatted:(int)(current)];
}

- (NSString *)durationStr {
    //视频的总长度
    NSTimeInterval total = CMTimeGetSeconds(self.player.currentItem.duration);
    return [self timeFormatted:(int)(total)];
}

#pragma mark - tool

//时间转换
- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60);
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

@end
