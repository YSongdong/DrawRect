//
//  ViewController.m
//  DrawRect
//
//  Created by tiao on 2021/2/4.
//  Copyright © 2021 wutiao. All rights reserved.
//

#import "ViewController.h"
#import "SDDrawBardView.h"


@interface ViewController () <SDDrawBardViewDelegate,GCDAsyncSocketDelegate>
// 手势图层view
@property (nonatomic,strong) SDDrawBardView *drawView;
// 背景img
@property (nonatomic,strong) UIImage *bgimg;
// 背景imageV
@property (nonatomic,strong) UIImageView *bgimgView;
// 图片宽度比
@property (nonatomic,assign) double  wRatio;
// 客户端socket
@property (strong, nonatomic) GCDAsyncSocket *clientSocket;
// 发送数据源
@property (nonatomic,strong) DataByteModel *sendModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.wRatio = 0;
    
    // 背景图
    self.bgimg = [UIImage imageNamed:@"WechatIMG2.jpeg"];
    self.wRatio = self.bgimg.size.width/[UIScreen mainScreen].bounds.size.width;
    double  h = self.bgimg.size.height/self.wRatio;
    self.bgimgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, h)];
    [self.view addSubview:self.bgimgView];
    self.bgimgView.image = self.bgimg;
    
    //手势视图
    self.drawView = [[SDDrawBardView alloc]initWithFrame:CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, h)];
    [self.view addSubview:self.drawView];
    self.drawView.backgroundColor = [UIColor clearColor];
    self.drawView.state = noState;
    self.drawView.delegate = self;
    
    // 截图一
    UIImageView *drawImagV = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.drawView.frame)+10, 150, 200)];
    [self.view addSubview:drawImagV];
    drawImagV.tag = 1000;
    
    UIImageView *drawImagV1 = [[UIImageView alloc]initWithFrame:CGRectMake(180, CGRectGetMaxY(self.drawView.frame)+10, 150, 200)];
    [self.view addSubview:drawImagV1];
    drawImagV1.tag = 1001;
    
    NSArray *arr = @[@"截图一",@"截图二",@"确定"];
    CGFloat w = (Width-40)/3;
    for (int i=0; i<arr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:btn];
        btn.frame = CGRectMake(10+i*w+i*10, Height-80, w, 40);
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        btn.tag = 2000+i;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [UIColor blackColor].CGColor;
        [btn addTarget:self action:@selector(selectABtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}
-(void)selectABtnAction:(UIButton*)sender{
    switch (sender.tag-2000) {
        case 0:
        {
            UIButton *btn = [self.view viewWithTag:2001];
            btn.selected = NO;
            self.drawView.state = oneState;
            sender.selected = YES;
            break;
        }
            
       case 1:
           {
             UIButton *btn = [self.view viewWithTag:2000];
              btn.selected = NO;
             sender.selected = YES;
             self.drawView.state = twoState;
             break;
            }
            case 2:
            {
//              UIButton *btn = [self.view viewWithTag:2000];
//               btn.selected = NO;
//              sender.selected = YES;
              self.drawView.state = noState;
                
                [self createSocket];
              break;
             }
        default:
            break;
    }
}



-(void) touchesEndedStartPoint:(CGPoint)startPoint andEndPoint:(CGPoint)endPoint{
    CGFloat x = startPoint.x * self.wRatio;
    CGFloat y = startPoint.y * self.wRatio;
    CGFloat w = (endPoint.x - startPoint.x) * self.wRatio;
    CGFloat h = (endPoint.y - startPoint.y) * self.wRatio;

    UIImageView *drawImagV;
    if (self.drawView.state == oneState) {
        drawImagV = [self.view viewWithTag:1000];
    }else{
       drawImagV = [self.view viewWithTag:1001];
    }
    drawImagV.image = [self cutImageFromOrignalImage:CGRectMake(x, y, w, h)];
    
    
    if (self.drawView.state ==  twoState) {
        return;
    }
    self.sendModel = [[DataByteModel alloc]init];
    self.sendModel.header = @"<@@>";
    self.sendModel.width = ceilf(w);
    self.sendModel.height = ceilf(h);
    self.sendModel.imageId = @"1a";
    
    ImageByte *imageByte = [[ImageByte alloc]init];
    imageByte.paramertId = 1;
    imageByte.startX = ceilf(x);
    imageByte.startY = ceilf(y);
    imageByte.width = ceilf(w);
    imageByte.height = ceilf(h);
    
    UIImage *image = [self cutImageFromOrignalImage:CGRectMake(x, y, w, h)];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    imageByte.imageSize =(int)imageData.length;
    imageByte.imageData = imageData;
    
    self.sendModel.imageByte = imageByte;

}
//截取图片
-(UIImage *)cutImageFromOrignalImage:(CGRect)rect{
    CGImageRef imgRef = CGImageCreateWithImageInRect([self.bgimg CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    return img;
}

#pragma mark ------- socket-------
-(void)createSocket{
    self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    [self.clientSocket connectToHost:@"192.168.3.145" onPort:9999 viaInterface:nil withTimeout:-1 error:&error];
    // 发送数据包
    [self sendMessageAction];
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"连接主机对应端口%@", sock);
    // 连接后,可读取服务端的数据
    [self.clientSocket readDataWithTimeout:- 1 tag:0];
}
// 发送数据
- (void)sendMessageAction{
    NSMutableData *imageByteData = [[NSMutableData alloc]init];
    NSData *paramertIdData = [SDTool intToData:self.sendModel.imageByte.paramertId];
    [imageByteData appendData:paramertIdData];
    
    NSData *startXData = [SDTool intToData:self.sendModel.imageByte.startX];
    [imageByteData appendData:startXData];
    
    NSData *startYData = [SDTool intToData:self.sendModel.imageByte.startY];
    [imageByteData appendData:startYData];
    
    NSData *widthData = [SDTool intToData:self.sendModel.imageByte.width];
    [imageByteData appendData:widthData];
    
    NSData *heightData = [SDTool intToData:self.sendModel.imageByte.height];
    [imageByteData appendData:heightData];
    
    NSData *lengData = [SDTool intToData:(int)self.sendModel.imageByte.imageData.length];
    [imageByteData appendData:lengData];

    [imageByteData appendData:self.sendModel.imageByte.imageData];
 
    NSMutableData *byteData = [[NSMutableData alloc]init];
    NSData *byteWidthData = [SDTool intToData:self.sendModel.width];
    [byteData appendData:byteWidthData];
    
    NSData *btyeHeightData = [SDTool intToData:self.sendModel.height];
    [byteData appendData:btyeHeightData];
    
    NSData *btyeIdData = [SDTool intToData:(int)self.sendModel.imageId.length];
    [byteData appendData:btyeIdData];
    
    NSData *btyeimageIdData = [self.sendModel.imageId dataUsingEncoding:NSUTF8StringEncoding];
    [byteData appendData:btyeimageIdData];
    
    [byteData appendData:imageByteData];
    
    
    NSMutableData *data = [[NSMutableData alloc]init];
    NSData *headerData = [self.sendModel.header dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:headerData];
    
    NSData *btyeLengthData = [SDTool intToData:(int)byteData.length];
    [data appendData:btyeLengthData];
    
    [data appendData:byteData];
    
    [self.clientSocket writeData:data withTimeout:-1 tag:0];
    
    NSLog(@"----%@---",[imageByteData hexString]);
   
}

/**
 读取数据
 @param sock 客户端socket
 @param data 读取到的数据
 @param tag 本次读取的标记
 */
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    // 读取到服务端数据值后,能再次读取
    [self.clientSocket readDataWithTimeout:- 1 tag:0];
}




@end
