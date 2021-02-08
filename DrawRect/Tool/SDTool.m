//
//  SDTool.m
//  DrawRect
//
//  Created by tiao on 2021/2/7.
//  Copyright © 2021 wutiao. All rights reserved.
//

#import "SDTool.h"

@implementation SDTool

+ (NSData *)intToData:(int)value{
    Byte byte[4] = {};
    byte[0] =  (Byte) (value & 0xFF);
    byte[1] =  (Byte) ((value>>8) & 0xFF);
    byte[2] =  (Byte) ((value>>16) & 0xFF);
    byte[3] =  (Byte) ((value>>24) & 0xFF);
    NSData *data = [NSData dataWithBytes:byte length:4];
    return data;
}



@end
