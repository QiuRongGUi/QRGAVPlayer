//
//  ViewController.m
//  音频--AVPlayer
//
//  Created by QIUGUI on 2017/9/10.
//  Copyright © 2017年 QIUGUI. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

/** <#class#>*/
@property(nonatomic,strong) AVPlayer  *player;

/** <#class#>*/
@property(nonatomic,strong) AVPlayerItem  *songItem;

@property (nonatomic, strong) id timeObserver;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)play:(id)sender {
    
    NSLog(@"播放 --- ");
        
    NSString *str = @"http://wvoice.spriteapp.cn/voice/2017/0621/5949863f84299.mp3";
    //创建URL  
    NSURL *url = [NSURL URLWithString:str];  
    self.songItem = [[AVPlayerItem alloc] initWithURL:url];
    //创建播放器  
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.songItem];  
    
    
    //// 1   监听改播放器状态
    [self.songItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
     // 2 监控播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.songItem];
    
//    3、监听播放进度
//    
//    使用addPeriodicTimeObserverForInterval:queue:usingBlock:来监听播放器的进度
//    (1）方法传入一个CMTime结构体，每到一定时间都会回调一次，包括开始和结束播放
//     (2）如果block里面的操作耗时太长，下次不一定会收到回调，所以尽量减少block的操作耗时
//      (3）方法会返回一个观察者对象，当播放完毕时需要移除这个观察者    
    __weak typeof(self) weakSelf = self;
    
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);        
        float total = CMTimeGetSeconds(weakSelf.songItem.duration);        
        if (current) {            
//            NSLog(@"%f--pross",current / total);
//            NSLog(@"%@--current",[NSString stringWithFormat:@"%.f",current]);
//            NSLog(@"%@--total",[NSString stringWithFormat:@"%.2f",total]);
            
            
//            weakSelf.progress = current / total;            
//            weakSelf.playTime = [NSString stringWithFormat:@"%.f",current];            
//            weakSelf.playDuration = [NSString stringWithFormat:@"%.2f",total];  
        }
    }];
    
//    获取播放时间
//    
//    AVPlayer并没有直接提供API来获取播放时间,需要我们通过计算得到
//    AVPlayer下有个CMTime这个属性,这个属性由value和timeScale组成,前者除以后者就可以得出秒数
//    通过CMTimeGetSeconds([_player currentTime]) / 60可以获得当前分钟,CMTimeGetSeconds([_player currentTime]) % 60可以获得当前秒数
//    通过playerItem.duration.value / _playerItem.duration.timescale / 60可以获得视频总分钟数,通过playerItem.duration.value / _playerItem.duration.timescale % 60可以获得视频总时间减分钟的秒数
//    通过以上几种计算方式搭配定时器就可以设置视频当前播放时长和视频总时长
    
      
    //4 .监控缓冲加载情况属性
    [self.songItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
      
}
- (IBAction)next:(id)sender {
    
    NSLog(@"下一首 --- ");
    
    NSString *str = @"http://wvoice.spriteapp.cn/voice/2017/0624/594e629d70787.mp3";
    
    // 通过下面的逻辑,只要AVPlayer有currentItem,那么一定被添加了观察者.
    //    // 所以上来直接移除之.
    if (self.player.currentItem) {
        NSLog(@"removeObserver --- ");
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    // 根据传入的URL(MP3歌曲地址),创建一个item对象
    // initWithURL的初始化方法建立异步链接. 什么时候连接建立完成我们不知道.但是它完成连接之后,会修改自身内部的属性status. 所以,我们要观察这个属性,当它的状态变为AVPlayerItemStatusReadyToPlay时,我们便能得知,播放器已经准备好,可以播放了.
    AVPlayerItem * item = [[ AVPlayerItem alloc] initWithURL:[NSURL URLWithString:str]];
    
    // 为item的status添加观察者.
    [item addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    
    // 用新创建的item,替换AVPlayer之前的item.新的item是带着观察者的哦.
    [self.player replaceCurrentItemWithPlayerItem:item];

}

- (void)playbackFinished:(NSNotification *)notice {    
    
    NSLog(@"播放完成");    
    
    [self.songItem removeObserver:self forKeyPath:@"status"];
    
//    if (timeObserve) {
//        [player removeTimeObserver:_timeObserve];
//        timeObserve = nil;
//    }
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {            
            case AVPlayerStatusUnknown:                
                NSLog(@"KVO：未知状态，此时不能播放");                
                break;            
            case AVPlayerStatusReadyToPlay:                
                                
//                self.status = SUPlayStatusReadyToPlay;                    
                NSLog(@"KVO：准备完毕，可以播放");           
                
                [self.player play];   // 播放
                
                break;
            case AVPlayerStatusFailed:
                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
                break;            
            default:                
                break;        
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = self.songItem.loadedTimeRanges;
        //本次缓冲时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        //缓冲总长度
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        NSLog(@"共缓冲：%.2f",totalBuffer);
               
    }
    
}



@end
