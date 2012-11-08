//
//  AudioPlayer.m
//  AudioToolBoxTest
//
//  Created by 杨飞 on 11/8/12.
//  Copyright (c) 2012 yf. All rights reserved.
//

#import "AudioPlayer.h"
/**
    定义回调函数
 */
typedef OSStatus (*AudioFile_ReadProc)(
void *		inClientData,
SInt64		inPosition,
UInt32	requestCount,
void *		buffer,
UInt32 *	actualCount);

@interface AudioPlayer()


@end

@implementation AudioPlayer

- (id)init
{
    if (self == [super init]) {
        
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)playAudio
{
    
}

@end
