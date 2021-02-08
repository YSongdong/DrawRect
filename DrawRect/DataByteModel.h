//
//  DataByteModel.h
//  DrawRect
//
//  Created by tiao on 2021/2/7.
//  Copyright © 2021 wutiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageByte;

@interface DataByteModel : NSObject
// 报头
@property (nonatomic , copy) NSString *header;
// width
@property (nonatomic,assign) int width;
// Height
@property (nonatomic,assign) int height;
// id
@property (nonatomic , copy) NSString *imageId;

@property (nonatomic , strong) ImageByte *imageByte;

@end

@interface ImageByte : NSObject
// id
@property (nonatomic,assign) int paramertId;
// x
@property (nonatomic,assign) int startX;
// y
@property (nonatomic,assign) int startY;
// width
@property (nonatomic,assign) int width;
// Height
@property (nonatomic,assign) int height;
// ImageSize
@property (nonatomic,assign) int imageSize;
// 图片
@property (nonatomic,copy) NSData *imageData;

@end

