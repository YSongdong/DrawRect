//
//  SDDrawBardView.m
//  DrawRect
//
//  Created by tiao on 2021/2/5.
//  Copyright © 2021 wutiao. All rights reserved.
//

#import "SDDrawBardView.h"

typedef enum {
    noStyle,  // 没有样式
    oneStyle, // 样式一
    twoStyle, // 样式二
}SelectStyle;
// 保存点的位置数组
static NSMutableArray *_pointArr;
// 保存线条数组
static NSMutableArray *_lineArr;

@implementation SDDrawBardView{
    UIPanGestureRecognizer *_pan; // 拖动手势
     SelectStyle _style; // 样式状态
    BOOL  _isMoved;  // 状态值
}
+(void)initialize{
    _pointArr = [NSMutableArray array];
    _lineArr = [NSMutableArray array];
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initData];
    }
    return self;
}
-(void)initData{
    self.userInteractionEnabled = NO;
    _style = noStyle;
    // 添加拖动手势
   _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
   [self addGestureRecognizer:_pan];
}
#pragma mark ~~~~~~~~~~ 屏幕事件 ~~~~~~~~~~
// 手指在屏幕上移动时调用
static CGPoint _handPoint;
-(void)pan:(UIPanGestureRecognizer*)pan{
    [self backCiclk];
    if (pan.state == UIGestureRecognizerStateChanged || pan.state == UIGestureRecognizerStateBegan){
           // 获取手指移动的位置
           _handPoint = [pan locationInView:self];
           // 将位置保存到数组中
           [_pointArr addObject:NSStringFromCGPoint(_handPoint)];
           // 绘制图形
           [self setNeedsDisplay];
       } else if (pan.state == UIGestureRecognizerStateEnded) {
           if (_state == oneState) {
               if ([self getWithArrKey:@"one"]) {
                   NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                   dict[@"key"] = @"one";
                   NSArray *array = [NSArray arrayWithArray:_pointArr];
                   dict[@"value"] =array;
                   [_lineArr replaceObjectAtIndex:0 withObject:dict];
               } else{
                   NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                   dict[@"key"] = @"one";
                   NSArray *array = [NSArray arrayWithArray:_pointArr];
                   dict[@"value"] =array;
                   [_lineArr insertObject:dict atIndex:0];
               }
           }else if (_state == twoState){
               if ([self getWithArrKey:@"two"]) {
                   NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                   dict[@"key"] = @"two";
                   NSArray *array = [NSArray arrayWithArray:_pointArr];
                   dict[@"value"] =array;
                   [_lineArr replaceObjectAtIndex:1 withObject:dict];
               }else{
                   NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                   dict[@"key"] = @"two";
                   NSArray *array = [NSArray arrayWithArray:_pointArr];
                   dict[@"value"] =array;
                   if (_lineArr.count > 0) {
                       [_lineArr insertObject:dict atIndex:1];
                   }else{
                       [_lineArr addObject:dict];
                   }
               }
           }
           if ([self.delegate respondsToSelector:@selector(touchesEndedStartPoint:andEndPoint:)]) {
               CGPoint startPoint = CGPointFromString(_pointArr[0]);
               CGPoint endPoint = CGPointFromString(_pointArr[_pointArr.count-1]);
               [self.delegate touchesEndedStartPoint:startPoint andEndPoint:endPoint];
           }
           // 清空当前点的位置数组,以便重新绘制图形
           [_pointArr removeAllObjects];
       }
}
// 通过key 在数组中是否找到
-(BOOL) getWithArrKey:(NSString*)key{
    BOOL  isFond = NO;
    if (_lineArr.count == 0) {
        return isFond;
    }
    for (int i=0; i<_lineArr.count; i++) {
        NSDictionary *dict = _lineArr[i];
        if ([dict[@"key"] isEqualToString:key]) {
            isFond = YES;
        }
    }
    return isFond;
}
#pragma mark ~~~~~~~~~~ 返回操作 ~~~~~~~~~~
-(void)backCiclk{
    if (_lineArr.count == 0) return;
    if (_state == oneState) {
        if ([self getWithArrKey:@"one"]) {
           [_lineArr removeObjectAtIndex:0];
        }
    }else{
        if (_lineArr.count == 1 && [self getWithArrKey:@"two"]) {
           [_lineArr removeObjectAtIndex:0];
        }else{
            if ([self getWithArrKey:@"two"]) {
               [_lineArr removeObjectAtIndex:1];
            }
        }
    }
}
#pragma mark ~~~~~~~~~~ 绘制图形 ~~~~~~~~~~
static CGContextRef _context;
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // 获取图形上下文
    _context = UIGraphicsGetCurrentContext();
    // 设置线条的样式
    CGContextSetLineCap(_context, kCGLineCapRound);
    // 设置线条转角样式
    CGContextSetLineJoin(_context, kCGLineJoinRound);
    
    // 判断之前是否有线条需要重绘
    if (_lineArr.count > 0) {
        for (int i=0; i<_lineArr.count; i++) {
            NSDictionary *dict = _lineArr[i];
            // 取出第i个线重新绘制
            NSArray *array = dict[@"value"];
            [self drawLineWithArrRect:array];
        }
    }
    [self drawLineWithArrRect:_pointArr];
}
// 画图形
- (void)drawLineWithArrRect:(NSArray*)arr{
    if (arr.count == 0) {
        return;
    }
    CGPoint startPoint = CGPointFromString(arr[0]);
    CGPoint endPoint = CGPointFromString(arr[arr.count-1]);

    //线框颜色
    CGContextSetStrokeColorWithColor(_context, [UIColor redColor].CGColor);
    //设置线宽
    CGContextSetLineWidth(_context,1);
    // 开始绘制
    CGContextBeginPath(_context);
    // 绘制起点
    CGContextMoveToPoint(_context, startPoint.x, startPoint.y);
    // 绘制终点
    CGContextAddRect(_context, CGRectMake(startPoint.x, startPoint.y, endPoint.x-startPoint.x, endPoint.y-startPoint.y));

    CGContextStrokePath(_context);
    
}

-(void)setState:(SelectState)state{
    _state =  state;
    if (state == noState) {
        self.userInteractionEnabled = NO;
    }else if(state == oneState){
        self.userInteractionEnabled = YES;
        
    }else{
        self.userInteractionEnabled = YES;
      
    }
}


@end
