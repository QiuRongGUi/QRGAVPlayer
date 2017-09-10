//
//  AVPlayerViewController.m
//  音频--AVPlayer
//
//  Created by QIUGUI on 2017/9/11.
//  Copyright © 2017年 QIUGUI. All rights reserved.
//

#import "AVPlayerViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface AVPlayerViewController ()

/** <#class#>*/
@property(nonatomic,strong) AVPlayer  *player;

/** <#class#>*/
@property(nonatomic,strong) id  timeObserver;

@end

@implementation AVPlayerViewController
//1、实例化一个AVPlayer：
- (AVPlayer *)player {
    if (_player == nil) {
        _player = [[AVPlayer alloc] init];
        _player.volume = 1.0; // 默认最大音量
    }
    return _player;
}

- (void)viewDidLoad {
    [super viewDidLoad];



}

- (IBAction)one:(id)sender {
    
    NSString *str = @"http://wvoice.spriteapp.cn/voice/2017/0624/594e629d70787.mp3";
    NSURL *url = [NSURL URLWithString:str];
    [self p_musicPlayerWithURL:url];
}


- (IBAction)clikePlayer:(id)sender {
    
    NSString *str = @"http://wvoice.spriteapp.cn/voice/2017/0621/5949863f84299.mp3";
    NSURL *url = [NSURL URLWithString:str];
    [self p_musicPlayerWithURL:url];

}



//2、播放一个音频（本地和网络都可以）
//播放音频的方法
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

//3、注册，使用KVO监听self.player.currentItem
//1、监听status，AVPlayerItemStatus有三种状态：
//typedef NS_ENUM(NSInteger, AVPlayerItemStatus) {
//    AVPlayerItemStatusUnknown,
//    AVPlayerItemStatusReadyToPlay,
//    AVPlayerItemStatusFailed
//};
//2、监听loadedTimeRanges，这个就是缓冲进度，可以进行缓冲进度条的设置
//3、AVPlayerItemDidPlayToEndTimeNotification，注册这个通知，当播放器播放完成的时候进行回调。
//4、addPeriodicTimeObserverForInterval，监听当前播放进度。
//

//3.监听和移除代码如下：
- (void)p_currentItemRemoveObserver {
    [self.player.currentItem removeObserver:self  forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.player removeTimeObserver:self.timeObserver];
}

- (void)p_currentItemAddObserver {
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
    
    //监控缓冲加载情况属性
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
    //监控播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
//    //监控时间进度
//    @weakify(self);
//    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
//        @strongify(self);
//        // 在这里将监听到的播放进度代理出去，对进度条进行设置
//        if (self.delegate && [self.delegate respondsToSelector:@selector(updateProgressWithPlayer:)]) {
//            [self.delegate updateProgressWithPlayer:self.player];
//        }
//    }];
}

//4、KVO处理
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
                // 代理回调，开始初始化状态
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
        // rate=1:播放，rate!=1:非播放
        float rate = self.player.rate;
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
}

/**
 播放
 */
- (void)play{
    
    [self.player play];
    
//    if (self.player == nil) {
//        return;
//    }
//    if (self.player.currentItem == nil) {
//        return;
//    }
//    if (self.player.rate) {
//        return;
//    } else {
//        if (self.player.status == AVPlayerStatusReadyToPlay) {
//            [self.player play];
//        }
//    }

}

/**
 暂停
 */
- (void)pause{
    
    [self.player pause];
    
//    if (self.player == nil) {
//        return;
//    }
//    if (self.player.currentItem == nil) {
//        return;
//    }
//    if (!self.player.rate) {
//        return;
//    } else {
//        if (self.player.status == AVPlayerStatusReadyToPlay) {
//            [self.player pause];
//        }
//    }

}

@end
