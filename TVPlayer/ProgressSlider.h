//
//  ProgressSlider.h
//  TVPlayer
//
//  Created by rick tao. on 17/1/19.
//  Copyright © 2016年 rick tao 陶伟胜. All rights reserved.
//

#import <UIKit/UIKit.h>

//进度条方向
typedef NS_ENUM(NSInteger, SliderDirection){
    SliderDirectionHorizonal  =   0,
    SliderDirectionVertical   =   1
};


@interface ProgressSlider : UIControl

@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGFloat sliderPercent;
@property (nonatomic, assign) CGFloat progressPercent;

@property (nonatomic, assign) BOOL isSliding;

@property (nonatomic, assign) SliderDirection direction;//方向

- (id)initWithFrame:(CGRect)frame direction:(SliderDirection)direction;

@end
