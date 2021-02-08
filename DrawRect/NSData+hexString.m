//
//  NSData+hexString.m
//  DrawRect
//
//  Created by tiao on 2021/2/7.
//  Copyright © 2021 wutiao. All rights reserved.
//

#import "NSData+hexString.h"

@implementation NSData (hexString)
- (NSString *)hexString{
    NSMutableString *mstr = [NSMutableString new];
    const Byte *bytes = [self bytes];
    for (int i = 0; i < self.length; i++) {
        [mstr appendFormat:@"%x ",bytes[i]];
    }
    return mstr;
}
@end
