//
//  PlayViewController.m
//  TVPlayer
//
//  Created by rick tao. on 17/1/19.
//  Copyright © 2016年 rick tao 陶伟胜. All rights reserved.
//

#import "PlayViewController.h"
#import "ProgressSlider.h"
#import "PlayerView.h"
#import "TVListModel.h"
#import <Masonry/Masonry.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;


@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;


@property (nonatomic, strong) UIView *bottmView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) ProgressSlider *slider;

@property (nonatomic, strong) UIActivityIndicatorView *activity;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) NSTimeInterval lastTime;

@property (strong, nonatomic) UIView *faildView;

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [self initPlayer];
    
    [self initPlayerSubViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayDidEnd)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}

//更新方法
- (void)upadte
{
    NSTimeInterval current = CMTimeGetSeconds(self.player.currentTime);
    NSTimeInterval total = CMTimeGetSeconds(self.player.currentItem.duration);
    //如果用户在手动滑动滑块，则不对滑块的进度进行设置重绘
    if (!self.slider.isSliding) {
        self.slider.sliderPercent = current/total;
    }
    
    if (current!=self.lastTime) {
        [self.activity stopAnimating];
        self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", [self formatPlayTime:current], isnan(total)?@"00:00:00":[self formatPlayTime:total]];
    }else{
        [self.activity startAnimating];
    }
    self.lastTime = current;
    
}

- (void)changeCurrentplayerItemWithTVListModel:(TVListModel *)model
{
    if (self.player) {
        
        self.link.paused = NO;
        self.playButton.selected = NO;
        
        [self removeObserveWithPlayerItem:self.player.currentItem];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_TVModel.tvURL]];
        [self addObserveWithPlayerItem:playerItem];
        self.playerItem = playerItem;
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        
        self.playButton.enabled = NO;
        self.slider.enabled = NO;
    }
}

#pragma mark - 监听视频缓冲和加载状态

- (void)addObserveWithPlayerItem:(AVPlayerItem *)playerItem
{
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserveWithPlayerItem:(AVPlayerItem *)playerItem
{
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [playerItem removeObserver:self forKeyPath:@"status"];
}

- (NSString *)formatPlayTime:(NSTimeInterval)duration
{
    int minute = 0, hour = 0, secend = duration;
    minute = (secend % 3600)/60;
    hour = secend / 3600;
    secend = secend % 60;
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, secend];
}

- (void)moviePlayDidEnd
{
        [self.player pause];
        [self.link invalidate];
        [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 点击事件
- (void)backAction:(UIButton *)button
{
    [self.player pause];
    [self.link invalidate];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadAction:(UIButton *)button
{
    [self changeCurrentplayerItemWithTVListModel:self.TVModel];
    self.faildView.hidden = YES;
}


- (void)playOrPauseAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (self.player.rate == 1) {
        [self.player pause];
        self.link.paused = YES;
        [self.activity stopAnimating];
    } else {
        [self.player play];
        self.link.paused = NO;
    }
}

- (void)progressValueChange:(ProgressSlider *)slider
{
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        NSTimeInterval duration = self.slider.sliderPercent* CMTimeGetSeconds(self.player.currentItem.duration);
        CMTime seekTime = CMTimeMake(duration, 1);
        
        [self.player seekToTime:seekTime completionHandler:^(BOOL finished) {
            
        }];
    }
}

- (void)showOrHideBar
{
    NSLog(@"%@",NSStringFromCGRect(self.topView.frame));
    
    if (self.topView.frame.origin.y >= 0) {
        
        [UIView animateWithDuration:.3 animations:^{
            
            [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).offset(-60);
            }];
            [self.bottmView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view).offset(60);
            }];
            
            [self.view layoutIfNeeded];
        }];
    }else {
        
        [UIView animateWithDuration:.3 animations:^{
            
            [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view);
            }];
            [self.bottmView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view);
            }];
            
            [self.view layoutIfNeeded];
        }];
        
    }
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSTimeInterval loadedTime = [self availableDurationWithplayerItem:playerItem];
        NSTimeInterval totalTime = CMTimeGetSeconds(playerItem.duration);
        
        if (!self.slider.isSliding) {
            self.slider.progressPercent = loadedTime/totalTime;
        }
        
    }else if ([keyPath isEqualToString:@"status"]){
        if (playerItem.status == AVPlayerItemStatusReadyToPlay){
            NSLog(@"playerItem is ready");
            
            [self.player play];
            self.slider.enabled = YES;
            self.playButton.enabled = YES;
        } else{
            NSLog(@"load break");
            self.faildView.hidden = NO;
        }
    }
}


- (NSTimeInterval)availableDurationWithplayerItem:(AVPlayerItem *)playerItem
{
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);
    NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - 全屏事件
- (void)fullScreen {

}


#pragma mark - 界面初始化

- (void)initPlayer {
    
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.TVModel.tvURL]];
    [self addObserveWithPlayerItem:self.playerItem];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    PlayerView *playerView = [[PlayerView alloc] initWithMoviePlayerLayer:self.playerLayer frame:self.view.bounds];
    playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:playerView];
    
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(upadte)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)initPlayerSubViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.topView = [[UIView alloc] initWithFrame:CGRectZero];
    self.topView.backgroundColor = [UIColor blackColor];
    self.topView.alpha = .5;
    [self.view addSubview:self.topView];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(60);
    }];
    
    
    self.backButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.backButton setImage:[UIImage imageNamed:@"gobackBtn"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.backButton];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).offset(10);
        make.top.equalTo(self.topView).offset(10);
        make.bottom.equalTo(self.topView).offset(-10);
        make.width.mas_equalTo(self.backButton.mas_height);
    }];
    
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = self.TVModel.tvName;
    [self.topView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.topView);
        make.size.mas_equalTo(CGSizeMake(self.view.frame.size.width - 100, 40));
    }];
    
    
    self.bottmView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottmView.backgroundColor = [UIColor blackColor];
    self.bottmView.alpha = .5;
    [self.view addSubview:self.bottmView];
    
    [self.bottmView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(60);
    }];
    
    self.playButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.playButton setImage:[UIImage imageNamed:@"pauseBtn"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"playBtn"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(playOrPauseAction:) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.enabled = NO;
    [self.bottmView addSubview:self.playButton];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottmView).offset(10);
        make.top.equalTo(self.bottmView).offset(10);
        make.bottom.equalTo(self.bottmView).offset(-10);
        make.width.mas_equalTo(self.backButton.mas_height);
    }];
    
    UIButton *fullScreenButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [fullScreenButton setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
    [fullScreenButton addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:fullScreenButton];
    
    [fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topView).offset(-10);
        make.top.equalTo(self.topView).offset(10);
        make.bottom.equalTo(self.topView).offset(-10);
        make.width.mas_equalTo(self.backButton.mas_height);
    }];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.text = @"00:00:00/00:00:00";
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.bottmView addSubview:self.timeLabel];
    CGSize size = CGSizeMake(1000,10000);
    
    NSDictionary *attribute = @{NSFontAttributeName:self.timeLabel.font};
    CGSize labelsize = [self.timeLabel.text boundingRectWithSize:size options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottmView).offset(-10);
        make.top.equalTo(self.bottmView).offset(10);
        make.bottom.equalTo(self.bottmView).offset(-10);
        make.width.mas_equalTo(labelsize.width + 5);
    }];
    
    
    self.slider = [[ProgressSlider alloc] initWithFrame:CGRectZero direction:SliderDirectionHorizonal];
    [self.bottmView addSubview:self.slider];
    self.slider.enabled = NO;
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.mas_right).offset(10);
        make.right.equalTo(self.timeLabel.mas_left).offset(-10);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(self.bottmView);
    }];
    
    [self.slider addTarget:self action:@selector(progressValueChange:) forControlEvents:UIControlEventValueChanged];
    
    
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activity.color = [UIColor redColor];
    [self.activity setCenter:self.view.center];
    [self.activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:self.activity];
    [self.activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.center.equalTo(self.view);
    }];
    
    
    self.faildView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.faildView];
    self.faildView.backgroundColor = [UIColor redColor];
    self.faildView.hidden = YES;
    
    [self.faildView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    //
    UIButton *reLoadButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [reLoadButton setTitle:@"视频加载失败，点击重新加载!" forState:UIControlStateNormal];
    [reLoadButton addTarget:self action:@selector(reloadAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.faildView addSubview:reLoadButton];
    
    [reLoadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.faildView);
    }];
    
    
    self.timeLabel.hidden = YES;
    self.slider.hidden = YES;
}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self showOrHideBar];
}
//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserveWithPlayerItem:_playerItem];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO ;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES ;
}

@end
