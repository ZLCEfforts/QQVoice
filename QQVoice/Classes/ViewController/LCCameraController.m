//
//  LCCameraController.m
//  墨迹天气
//
//  Created by 张沃仁 on 16/7/6.
//  Copyright © 2016年 ZLC. All rights reserved.
//

#import "LCCameraController.h"
#import "PrefixHeader.pch"
#import  <AVFoundation/AVFoundation.h>
#import "LCCameraFunctionView.h"


@interface LCCameraController ()<AVCaptureMetadataOutputObjectsDelegate>

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic)AVCaptureDevice *device;

//代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;

//当启动摄像头开始捕获输入
@property(nonatomic)AVCaptureMetadataOutput *output;

@property (nonatomic)AVCaptureStillImageOutput *ImageOutPut;

//把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;

// 退出按钮和返回
@property (nonatomic,strong) UIButton *exitButton;

// 相机切换按钮
@property (nonatomic,strong) UIButton *camera_switch_Btn;

// 功能View
@property (nonatomic,strong)LCCameraFunctionView  *cameraFunctionView;


@end

@implementation LCCameraController

- (void)viewDidLoad {
    [super viewDidLoad];

    BOOL is_permissions = [self canUserCamear];
    
    if(is_permissions){
        
        [self customCamera];
        [self customUI];
    }
}

#pragma mark - 初始化相机
- (void)customCamera{
    
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //从后置摄像头变换成前置摄像头
    self.device =  [self cameraWithPosition:AVCaptureDevicePositionFront];
    
    //使用设备初始化输入
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    
    //生成输出对象
    self.output = [[AVCaptureMetadataOutput alloc]init];
    self.ImageOutPut = [[AVCaptureStillImageOutput alloc] init];
    
    //生成会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc]init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
        
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.ImageOutPut]) {
        [self.session addOutput:self.ImageOutPut];
    }
    
    
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, PScreenWidth, PScreenHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    //开始启动
    [self.session startRunning];
    
    if ([_device lockForConfiguration:nil]) {
        
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
            
        }
        //自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}

#pragma mark - 初始化UI
- (void)customUI{
    
    UIView *top_view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, PScreenWidth, 200)];
    top_view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:top_view];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, 120, 30)];
    nameLabel.text = @"ZLC";
    nameLabel.font = [UIFont systemFontOfSize:23];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [UIColor whiteColor];
    [top_view addSubview:nameLabel];
    
    UILabel *stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 70, 120, 20)];
    stateLabel.text = @"等待对方接听...";
    stateLabel.font = [UIFont systemFontOfSize:16];
    stateLabel.textColor = [UIColor whiteColor];
    [top_view addSubview:stateLabel];
    
    //按钮
    self.camera_switch_Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.camera_switch_Btn.frame = CGRectMake(PScreenWidth - 60, 40, 40, 40);
    [self.camera_switch_Btn setImage:[UIImage imageNamed:@"avatar_record_switch_camera_nor"] forState:UIControlStateNormal];
    [self.camera_switch_Btn addTarget:self action:@selector(cameraChange) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.camera_switch_Btn];

    // X按钮 和 返回
    self.exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.exitButton.frame = CGRectMake(20, 90, 40, 40);
     self.exitButton.backgroundColor = [UIColor orangeColor];
    [self.exitButton setImage:[UIImage imageNamed:@"live_camera_close"] forState:UIControlStateNormal];
    [self.exitButton setImage:[UIImage imageNamed:@"live_camera_closeS"] forState:UIControlStateHighlighted];
    [self.exitButton addTarget:self action:@selector(exitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exitButton];

}



#pragma mark - 相机切换
- (void)cameraChange{
  
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        
        CATransition *animation = [CATransition animation];
        
        animation.duration = 0.3f;
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        animation.type = @"oglFlip";
        
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        //获取当前摄像头位置
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
           
            
        }else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromLeft;
           
        }
    
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        
        [self.previewLayer addAnimation:animation forKey:nil];
        
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:_input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
                
            } else {
                [self.session addInput:self.input];
            }
            
            [self.session commitConfiguration];
            
        }else if (error) {
            
            NSLog(@"toggle carema failed, error = %@", error);
        }
        
    }
    
}

#pragma mark - 返回前置摄像头 还是 后置摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if (device.position == position ){
            
            return device;
        }
    return nil;
}


#pragma mark - 退出按钮事件
-(void)exitButtonClick{
 
   [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - 检查相机权限
- (BOOL)canUserCamear{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied) {
    
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请打开相机权限" message:@"设置-隐私-相机" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
        
    }else{
        
        return YES;
    }
    return YES;
}

@end
