//
//  PlayerView.h
//  TVPlayer
//
//  Created by rick tao. on 17/1/19.
//  Copyright © 2016年 rick tao 陶伟胜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerView : UIView

- (instancetype)initWithMoviePlayerLayer:(AVPlayerLayer *)playerLayer frame:(CGRect)frame;


@end
