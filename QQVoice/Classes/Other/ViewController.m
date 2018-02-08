//
//  ViewController.m
//  QQVoice
//
//  Created by mac on 2018/2/7.
//  Copyright © 2018年 QQVoiceDemo. All rights reserved.
//

#import "ViewController.h"
#import "LCCameraController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
     [[LinphoneManager instance] startLinphoneCore];
    
    NSString *Account = @"2000004979";
    
    NSString *ip =@"120.25.78.167:35162";
    
     [[LCLinphoneConfig instance] registeByUserName:Account pwd:@"4dd8fc870e804cc282f487bb6b0c70bf" domain:ip tramsport:@"tcp"];
   
}


- (IBAction)pushBtnClick:(id)sender {
    
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    
     
        
        LCCameraController *camera  =[[LCCameraController alloc]init];

        [self presentViewController:camera animated:YES completion:nil];
        
//    }else{
//       
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"模拟器没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            
//            
//        }]];
//        
//        [self presentViewController:alert animated:YES completion:nil];
//    }
}

@end
