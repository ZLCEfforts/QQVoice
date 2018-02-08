//
//  LCLinphoneConfig.h
//  QQVoice
//
//  Created by mac on 2018/2/8.
//  Copyright © 2018年 QQVoiceDemo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCLinphoneConfig : NSObject

+ (LCLinphoneConfig *)instance;

- (void)registeByUserName:(NSString *)userName pwd:(NSString *)pwd domain:(NSString *)domain tramsport:(NSString *)transport;

//拨打电话
- (void)callPhoneWithPhoneNumber:(NSString *)phone withVideo:(BOOL)video;

- (void)switchCamera;

- (void)enableVideoCodecWithString:(NSString *)codec enable:(BOOL)enable;

- (NSMutableArray *)getAllEnableVideoCodec;

- (NSMutableArray *)getAllEnableAudioCodec;

- (void)acceptCall;

- (void)hold;

- (void)unhold;

- (void)remoteAccount;

- (void)haveCall;

- (void)muteMic;

- (void)enableSpeaker;

- (void)tabeSnapshot;

- (void)takePreviewSnapshot;

- (void)setVideoSize;

- (void)showVideo;

- (void)setRemoteVieoPreviewWindow:(UIView *)preview;

//- (void)setCurrentVideoPreviewWindow:(UIView *)preview;

//挂断电话
- (void)hangUpCall;

- (void)clearProxyConfig;

@end
