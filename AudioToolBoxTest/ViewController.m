//
//  ViewController.m
//  AudioToolBoxTest
//
//  Created by 杨飞 on 11/8/12.
//  Copyright (c) 2012 yf. All rights reserved.
//

#import "ViewController.h"
#import "AudioPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize audioPlayer = _audioPlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame = CGRectMake(0, 0, 60, 40);
    [button1 setTitle:@"play" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame = CGRectMake(60, 0, 60, 40);
    [button2 setTitle:@"pause" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button3.frame = CGRectMake(120, 0, 40, 40);
    [button3 setTitle:@"stop" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:button1];
    [self.view addSubview:button2];
    [self.view addSubview:button3];
}

- (void)pause:(UIButton *)sender
{
    [_audioPlayer pause];
}

- (void)play:(UIButton *)sender
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Music" ofType:@"mp3"];
    _audioPlayer = [[AudioPlayer alloc] initWithAudio:path];
    [_audioPlayer playAudio];
//    [_audioPlayer GetCurrentTime];
//    [_audioPlayer seekToTime];
    [_audioPlayer duration];
}

- (void)stop:(UIButton *)sender
{
    [_audioPlayer stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
