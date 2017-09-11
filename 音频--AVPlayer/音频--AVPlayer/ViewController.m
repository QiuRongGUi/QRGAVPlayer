//
//  ViewController.m
//  音频--AVPlayer
//
//  Created by QIUGUI on 2017/9/11.
//  Copyright © 2017年 QIUGUI. All rights reserved.
//

#import "ViewController.h"

#import "AVPlayerManager.h"

#import "Voice.h"


@interface ViewController ()


/** <#class#>*/
@property(nonatomic,strong) AVPlayerManager  *manager;

@end

@implementation ViewController

- (AVPlayerManager *)manager{
    
    if(!_manager){
        
        NSMutableArray *data = [NSMutableArray array];
        
        for(int i = 0;i< 4;i++){
            
            NSArray *array = @[@"http://wvoice.spriteapp.cn/voice/2017/0621/5949863f84299.mp3",@"http://wvoice.spriteapp.cn/voice/2017/0808/5989a4625337b.mp3",@"http://wvoice.spriteapp.cn/voice/2017/0808/5988c336532a5.mp3",@"http://wvoice.spriteapp.cn/voice/2017/0624/594e629d70787.mp3"];
            
            Voice *voice = [[Voice alloc] init];
            voice.index = i;
            voice.audioFileURL = [NSURL URLWithString:array[i]];
            [data addObject:voice];
            
        }

        AVPlayerManager *manager = [AVPlayerManager sharedManager];
        manager.voices = data;
        _manager = manager;
        
    }
    
    return _manager;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
  
      
}
- (IBAction)playOne:(id)sender {
    NSLog(@"播放一首");
    
    [self.manager playAnyVoiceWithIndex:1];
    
}
- (IBAction)pause:(id)sender {
    
    [self.manager pause];
}
- (IBAction)next:(id)sender {
    
    [self.manager playNext];
    
}
- (IBAction)last:(id)sender {
    
    [self.manager playPrevious];
}
- (IBAction)play:(id)sender {
 
    [self.manager play];
    
}
- (IBAction)clikeSlider:(UISlider *)sender {
        
    [self.manager setupCurrentVolume:sender.value];
}

- (IBAction)clikeCurrentTime:(UISlider *)sender {
    
    [self.manager setupCurrentTimeWithSilderValue:sender.value completion:nil];
    
}

@end
