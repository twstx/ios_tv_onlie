//
//  PlayerView.m
//  TVPlayer
//
//  Created by rick tao. on 17/1/19.
//  Copyright © 2016年 rick tao 陶伟胜. All rights reserved.
//
#import "PlayerView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PlayerView ()

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation PlayerView

- (instancetype)initWithMoviePlayerLayer:(AVPlayerLayer *)playerLayer frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _playerLayer = playerLayer;
        playerLayer.backgroundColor = [UIColor blackColor].CGColor;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _playerLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_playerLayer];
    }
    return self;
}


- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    
    _playerLayer.bounds = self.layer.bounds;
    _playerLayer.position = self.layer.position;
}

@end
