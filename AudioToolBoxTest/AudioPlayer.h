//
//  AudioPlayer.h
//  AudioToolBoxTest
//
//  Created by 杨飞 on 11/8/12.
//  Copyright (c) 2012 yf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioToolBox/AudioToolBox.h"

@interface AudioPlayer : NSObject
{
    AudioFileStreamID fileStreamId;// 文件流
    AudioQueueRef queueRef;// 播放队列
    AudioStreamBasicDescription streamBasicDes;// 格式化音频数据
    AudioQueueBufferRef queueBufferRef;// 数据缓冲
    
    OSStatus error;// 错误信息
}

- (void)playAudio;
@end
