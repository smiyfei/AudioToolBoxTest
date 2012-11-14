//
//  AudioPlayer.h
//  AudioToolBoxTest
//
//  Created by 杨飞 on 11/8/12.
//  Copyright (c) 2012 yf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioToolBox/AudioToolBox.h"

#define NUM_BUFFERS 3

@interface AudioPlayer : NSObject
{
    AudioFileID audioFileID;//播放音频文件id
    AudioStreamBasicDescription asbd;//音频描述
    
    AudioQueueRef audioQueue;//播放队列
    
    SInt64 packetIndex; 
    UInt32 numPacketsToRead;
    UInt32 bufferByteSize;
    
    AudioStreamPacketDescription *audioStreamPacketDesc;
    AudioQueueBufferRef buffers[NUM_BUFFERS];
}

@property AudioQueueRef audioQueue;

- (id)initWithAudio:(NSString *)path;
- (void)audioQueueOutputWithQueue:(AudioQueueRef)audioQueue
                      queueBuffer:(AudioQueueBufferRef)audioQueueBuffer;
- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer;

static void BufferCallback(void *inUserData,AudioQueueRef inAQ,AudioQueueBufferRef buffer);

- (void)playAudio;
- (void)pause;
- (void)stop;
- (void)GetCurrentTime;
@end
