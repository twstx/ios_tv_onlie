//
//  ProgressSlider.m
//  TVPlayer
//
//  Created by rick tao. on 17/1/19.
//  Copyright © 2016年 rick tao 陶伟胜. All rights reserved.
//

#import "ProgressSlider.h"

@interface ProgressSlider ()

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *slidedLineColor;
@property (nonatomic, strong) UIColor *progressLineColor;
@property (nonatomic, strong) UIColor *circleColor;

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat circleRadius;

@end

@implementation ProgressSlider

- (id)initWithFrame:(CGRect)frame direction:(SliderDirection)direction{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _minValue = 0;
        _maxValue = 1;
        
        _direction = direction;
        _lineColor = [UIColor whiteColor];
        _slidedLineColor = [UIColor colorWithRed:254/255.0 green:40/255.0 blue:80/255.0 alpha:1.0];
;
        _circleColor = [UIColor colorWithRed:254/255.0 green:40/255.0 blue:80/255.0 alpha:1.0];
;
        _progressLineColor = [UIColor grayColor];
        
        _sliderPercent = 0.0;
        _lineWidth = 2;
        _circleRadius = 8;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //画总体的线
    CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);//画笔颜色
    CGContextSetLineWidth(context, _lineWidth);//线的宽度
    
    CGFloat startLineX = (_direction == SliderDirectionHorizonal ? _circleRadius : (self.frame.size.width - _lineWidth) / 2);
    CGFloat startLineY = (_direction == SliderDirectionHorizonal ? (self.frame.size.height - _lineWidth) / 2 : _circleRadius);//起点
    
    CGFloat endLineX = (_direction == SliderDirectionHorizonal ? self.frame.size.width - _circleRadius : (self.frame.size.width - _lineWidth) / 2);
    CGFloat endLineY = (_direction == SliderDirectionHorizonal ? (self.frame.size.height - _lineWidth) / 2 : self.frame.size.height- _circleRadius);//终点
    
    CGContextMoveToPoint(context, startLineX, startLineY);
    CGContextAddLineToPoint(context, endLineX, endLineY);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    
    //绘制缓冲进度的线
    CGContextSetStrokeColorWithColor(context, _progressLineColor.CGColor);//画笔颜色
    CGContextSetLineWidth(context, _lineWidth);//线的宽度
    
    CGFloat progressLineX = (_direction == SliderDirectionHorizonal ? MAX(_circleRadius, (_progressPercent * self.frame.size.width - _circleRadius)) : startLineX);
    
    CGFloat progressLineY = (_direction == SliderDirectionHorizonal ? startLineY : MAX(_circleRadius, (_progressPercent * self.frame.size.height - _circleRadius)));
    
    CGContextMoveToPoint(context, startLineX, startLineY);
    CGContextAddLineToPoint(context, progressLineX, progressLineY);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    
    //画已滑动进度的线
    CGContextSetStrokeColorWithColor(context, _slidedLineColor.CGColor);//画笔颜色
    CGContextSetLineWidth(context, _lineWidth);//线的宽度
    
    CGFloat slidedLineX = (_direction == SliderDirectionHorizonal ? MAX(_circleRadius, (_sliderPercent * (self.frame.size.width - 2*_circleRadius) + _circleRadius)) : startLineX);
    
    CGFloat slidedLineY = (_direction == SliderDirectionHorizonal ? startLineY : MAX(_circleRadius, (_sliderPercent * self.frame.size.height - _circleRadius)));
    
    CGContextMoveToPoint(context, startLineX, startLineY);
    CGContextAddLineToPoint(context, slidedLineX, slidedLineY);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    //外层圆
    CGFloat penWidth = 1.f;
    CGContextSetStrokeColorWithColor(context, _circleColor.CGColor);//画笔颜色
    CGContextSetLineWidth(context, penWidth);//线的宽度
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);//填充颜色
    
    CGContextSetShadow(context, CGSizeMake(1, 1), 1.f);//阴影
    
    CGFloat circleX = (_direction == SliderDirectionHorizonal ? MAX(_circleRadius + penWidth, slidedLineX - penWidth ) : startLineX);
    CGFloat circleY = (_direction == SliderDirectionHorizonal ? startLineY : MAX(_circleRadius + penWidth, slidedLineY - penWidth));
    CGContextAddArc(context, circleX, circleY, _circleRadius, 0, 2 * M_PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充
    
    
    //内层圆
    CGContextSetStrokeColorWithColor(context, nil);
    CGContextSetLineWidth(context, 0);
    CGContextSetFillColorWithColor(context, _circleColor.CGColor);
    CGContextAddArc(context, circleX, circleY, _circleRadius / 2, 0, 2 * M_PI, 0);
    CGContextDrawPath(context, kCGPathFillStroke);
    
}

#pragma mark 触摸
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.enabled) {
        return;
    }
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.enabled) {
        return;
    }
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.enabled) {
        return;
    }
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.enabled) {
        return;
    }
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:YES];
}


- (void)updateTouchPoint:(NSSet*)touches {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    self.sliderPercent = (_direction == SliderDirectionHorizonal ? touchPoint.x : touchPoint.y) / (_direction == SliderDirectionHorizonal ? self.frame.size.width : self.frame.size.height);
}

- (void)setSliderPercent:(CGFloat)sliderPercent {
    if (_sliderPercent != sliderPercent) {
        _sliderPercent = sliderPercent;
        
        self.value = _minValue + sliderPercent * (_maxValue - _minValue);
    }
}

- (void)setProgressPercent:(CGFloat)progressPercent
{
    if (_progressPercent != progressPercent) {
        _progressPercent = progressPercent;
        [self setNeedsDisplay];
    }
}

- (void)setValue:(CGFloat)value {
    
    if (value != _value) {
        if (value < _minValue) {
            _value = _minValue;
            return;
        } else if (value > _maxValue) {
            _value = _maxValue;
            return;
        }
        _value = value;
        _sliderPercent = (_value - _minValue)/(_maxValue - _minValue);
        [self setNeedsDisplay];
    }
}


- (void)callbackTouchEnd:(BOOL)isTouchEnd {
    _isSliding = !isTouchEnd;
    if (isTouchEnd == YES) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}


@end
