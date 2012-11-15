//
//  AudioPlayer.m
//  AudioToolBoxTest
//
//  Created by 杨飞 on 11/8/12.
//  Copyright (c) 2012 yf. All rights reserved.
//

#import "AudioPlayer.h"
#include <mach/mach_time.h>
#include <CoreAudio/CoreAudioTypes.h>

static UInt32 gBufferSizeBytes=0x10000;//It muse be pow(2,x)

@implementation AudioPlayer

@synthesize audioQueue;

- (id)initWithAudio:(NSString *)path
{
    if (self == [super init])
    {
        [self createQueueWithAudioPath:path];
    }
    
    return self;
}

- (void)playAudio
{
    Float32 gain = 1.0;
    AudioQueueSetParameter(audioQueue,kAudioQueueParam_Volume, gain);
    AudioQueueStart(audioQueue, nil);
}

- (void)pause
{
    AudioQueuePause(audioQueue);
}

- (void)stop
{
    AudioQueueStop(audioQueue, false);
}

- (double)duration
{
    double duration = 0.0;
    AudioTimeStamp timeStamp;
    AudioQueueGetCurrentTime(audioQueue, NULL, &timeStamp, NULL);
    
    
    return duration;
}

- (void)GetCurrentTime
{
    if (audioQueue != nil)
    {
        Float64 timeInterval;
        AudioQueueTimelineRef timeLine;
        AudioTimeStamp timeStamp;
        OSStatus status = AudioQueueCreateTimeline(audioQueue, &timeLine);
        if(status == noErr)
        {
            AudioQueueGetCurrentTime(audioQueue, timeLine, &timeStamp, NULL);
            timeInterval = timeStamp.mSampleTime * 1000000 / asbd.mSampleRate; // modified
            NSLog(@"sample rate : %f",asbd.mSampleRate);
            NSLog(@"%f",timeInterval);
        }
    }
    
}

- (void)seekToTime:(double)seekTime
{
//    struct AudioTimeStamp
//    {
//        Float64         mSampleTime;
//        UInt64          mHostTime;
//        Float64         mRateScalar;
//        UInt64          mWordClockTime;
//        SMPTETime       mSMPTETime;
//        UInt32          mFlags;
//        UInt32          mReserved;
//    };
//    typedef struct AudioTimeStamp   AudioTimeStamp;
    
    
//    AudioTimeStamp timeStamp = {0};
//    SInt32 theNumberOfSecondsInTheFuture = -5;
    UInt64 absolute_time = mach_absolute_time();
    NSLog(@"absolute_time : %lli",absolute_time);

//    AudioQueueStart(audioQueue, &timeStamp);
    const int64_t kOneMillion = 1000 * 1000;
    static mach_timebase_info_data_t s_timebase_info;
    
    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }
    
    // mach_absolute_time() returns billionth of seconds,
    // so divide by one million to get milliseconds
    NSLog(@"test time : %i",(int)((mach_absolute_time() * s_timebase_info.numer) / (kOneMillion * s_timebase_info.denom)));
    
}

//回调函数(Callback)的实现
static void BufferCallback(void *inUserData,AudioQueueRef inAQ,
                           AudioQueueBufferRef buffer){
    NSLog(@"audioqueue new output finished");
    AudioPlayer* player=(AudioPlayer*)inUserData;
    [player audioQueueOutputWithQueue:inAQ queueBuffer:buffer];
}

//缓存数据读取方法的实现
-(void) audioQueueOutputWithQueue:(AudioQueueRef)audioQueueRef queueBuffer:(AudioQueueBufferRef)audioQueueBuffer{
    OSStatus status;
    
    //读取包数据
    UInt32 numBytes;
    UInt32 numPackets=numPacketsToRead;
    status = AudioFileReadPackets(audioFileID, NO, &numBytes, audioStreamPacketDesc, packetIndex,&numPackets, audioQueueBuffer->mAudioData);
    
    //成功读取时
    if (numPackets>0) {
        //将缓冲的容量设置为与读取的音频数据一样大小(确保内存空间)
        audioQueueBuffer->mAudioDataByteSize=numBytes;
        //完成给队列配置缓存的处理
        status = AudioQueueEnqueueBuffer(audioQueueRef, audioQueueBuffer, numPackets, audioStreamPacketDesc);
        //移动包的位置
        packetIndex += numPackets;
    }
    
    
    if (audioQueue != nil)
    {
        Float64 timeInterval;
        AudioQueueTimelineRef timeLine;
        AudioTimeStamp timeStamp;
        OSStatus status = AudioQueueCreateTimeline(audioQueue, &timeLine);
        if(status == noErr)
        {
            AudioQueueGetCurrentTime(audioQueue, timeLine, &timeStamp, NULL);
            Float64 sampleTime = timeStamp.mSampleTime;
            NSLog(@"%f",sampleTime);
            timeInterval = timeStamp.mSampleTime / asbd.mSampleRate; // modified
            
        }
    }
}

- (AudioQueueRef *)createQueueWithAudioPath:(NSString *)path
{
    UInt32 size,maxPacketSize;
    OSStatus status;
    char *cookie;
    
    status = AudioFileOpenURL((CFURLRef)[NSURL fileURLWithPath:path], kAudioFileReadPermission, 0, &audioFileID);
    if (status != noErr)
    {
        NSLog(@"could not open audio file. Path given was: %@", path);
        return nil;
    }
    
    //为播放队列分配缓冲区（此处设置为3个）
    for (int i = 0; i < NUM_BUFFERS; i++)
    {
        AudioQueueEnqueueBuffer(audioQueue, buffers[i], 0, nil);
    }
    
    //获取音频数据格式
    size = sizeof(asbd);
    AudioFileGetProperty(audioFileID, kAudioFilePropertyDataFormat, &size, &asbd);
    
    //创建播放用的音频队列
    AudioQueueNewOutput(&asbd, BufferCallback, self, nil, nil,0, &audioQueue);
    
    
    //计算单位时间包含的包数
    if (asbd.mBytesPerPacket == 0 || asbd.mFramesPerPacket == 0)
    {
        size = sizeof(maxPacketSize);
        AudioFileGetProperty(audioFileID, kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize);
        if (maxPacketSize > gBufferSizeBytes)
        {
            maxPacketSize = gBufferSizeBytes;
        }
        
        //算出单位时间内包含的包数
        numPacketsToRead = gBufferSizeBytes / maxPacketSize;
        audioStreamPacketDesc = malloc(sizeof(AudioStreamPacketDescription) * numPacketsToRead);
    }
    else
    {
        numPacketsToRead = gBufferSizeBytes / asbd.mBytesPerPacket;
        audioStreamPacketDesc = nil;
    }
    
    //设置magic cookie
    AudioFileGetProperty(audioFileID, kAudioFilePropertyMagicCookieData, &size, nil);
    if (size > 0)
    {
        cookie = malloc(sizeof(char)*size);
        AudioFileGetProperty(audioFileID, kAudioFilePropertyMagicCookieData, &size, cookie);
        AudioQueueSetProperty(audioQueue, kAudioQueueProperty_MagicCookie, cookie, size);
    }
    
    //创建并分配缓冲空间
    packetIndex = 0;
    for (int i = 0; i < NUM_BUFFERS; i++)
    {
        AudioQueueAllocateBuffer(audioQueue, gBufferSizeBytes, &buffers[i]);
        if ([self readPacketsIntoBuffer:buffers[i]] == 1)
        {
            break;
        }
        else
        {
            NSLog(@"buffer[%i] is filled",i);
        }
    }

    return &(audioQueue);
}


-(UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer
{
    UInt32 numBytes,numPackets;
    
    //从文件中接受数据并保存到缓存(buffer)中
    numPackets = numPacketsToRead;
    AudioFileReadPackets(audioFileID, NO, &numBytes, audioStreamPacketDesc, packetIndex, &numPackets, buffer->mAudioData);
    if(numPackets >0)
    {
        buffer->mAudioDataByteSize=numBytes;
        AudioQueueEnqueueBuffer(audioQueue, buffer, (audioStreamPacketDesc ? numPackets : 0), audioStreamPacketDesc);
        packetIndex += numPackets;
    }
    else
    {
        return 1;//意味着我们没有读到任何的包
    }
    
    return 0;//0代表正常的退出
}

- (void)dealloc
{
    [super dealloc];
}

@end
