//
//  SDDrawBardView.h
//  DrawRect
//
//  Created by tiao on 2021/2/5.
//  Copyright © 2021 wutiao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    noState,  // 没有选择
    oneState, // 状态一
    twoState, // 状态二
}SelectState;

@protocol SDDrawBardViewDelegate <NSObject>

-(void) touchesEndedStartPoint:(CGPoint)startPoint andEndPoint:(CGPoint)endPoint;

@end

@interface SDDrawBardView : UIView

@property (nonatomic,weak) id<SDDrawBardViewDelegate> delegate;

@property (nonatomic,assign) SelectState state;

@end


