//
//  LCLinphoneConfig.m
//  QQVoice
//
//  Created by mac on 2018/2/8.
//  Copyright © 2018年 QQVoiceDemo. All rights reserved.
//

#import "LCLinphoneConfig.h"

static LCLinphoneConfig *linphoneCfg = nil;

@implementation LCLinphoneConfig

+ (LCLinphoneConfig *)instance{
    
    @synchronized(self) {
        
        if (linphoneCfg == nil) {
            
            linphoneCfg = [[LCLinphoneConfig alloc] init];
        }
    }
    return linphoneCfg;
}
#pragma mark - 注册
- (void)registeByUserName:(NSString *)userName pwd:(NSString *)pwd domain:(NSString *)domain tramsport:(NSString *)transport{
    
    //设置超时
    linphone_core_set_inc_timeout(LC, 60);
    
    //创建配置表
    LinphoneProxyConfig *proxyCfg = linphone_core_create_proxy_config(LC);
    
    //初始化电话号码
    linphone_proxy_config_normalize_phone_number(proxyCfg,userName.UTF8String);
    
    //创建地址
    NSString *address = [NSString stringWithFormat:@"sip:%@@%@",userName,domain];//如:sip:123456@sip.com
    LinphoneAddress *identify = linphone_address_new(address.UTF8String);
    
    linphone_proxy_config_set_identity_address(proxyCfg, identify);
    
    linphone_proxy_config_set_route(
                                    proxyCfg,
                                    [NSString stringWithFormat:@"%s;transport=%s", domain.UTF8String, transport.lowercaseString.UTF8String]
                                    .UTF8String);
    linphone_proxy_config_set_server_addr(
                                          proxyCfg,
                                          [NSString stringWithFormat:@"%s;transport=%s", domain.UTF8String, transport.lowercaseString.UTF8String]
                                          .UTF8String);
    
    linphone_proxy_config_enable_register(proxyCfg, TRUE);
    
    
    //创建证书
    LinphoneAuthInfo *info = linphone_auth_info_new(userName.UTF8String, nil, pwd.UTF8String, nil, nil, linphone_address_get_domain(identify));
    
    //添加证书
    linphone_core_add_auth_info(LC, info);
    
    //销毁地址
    linphone_address_unref(identify);
    
    //注册
    linphone_proxy_config_enable_register(proxyCfg, 1);
    
    // 设置一个SIP路线  外呼必经之路
    linphone_proxy_config_set_route(proxyCfg,domain.UTF8String);
    
    //添加到配置表,添加到linphone_core
    linphone_core_add_proxy_config(LC, proxyCfg);
    
    //设置成默认配置表
    linphone_core_set_default_proxy_config(LC, proxyCfg);
    
    
    //设置音频编码格式
    //    [self synchronizeCodecs:linphone_core_get_audio_codecs(LC)];
    
    //    MSVideoSize vsize;
    //
    //    MS_VIDEO_SIZE_ASSIGN(vsize, 720P);
    //
    //    linphone_core_set_preferred_video_size(LC, vsize);
    
    //    [self synchronizeVideoCodecs:linphone_core_get_video_codecs(LC)];
    
    
    
    
    [self synchronizeCodecs:linphone_core_get_video_codecs(LC)];
    
    LinphoneVideoPolicy policy;
    policy.automatically_initiate =  YES;// 自动启动视频
    policy.automatically_accept =  YES; // 自动接听视频
    linphone_core_set_video_policy(LC, &policy);  // 设置视频参数
    
    linphone_core_enable_self_view(LC, NO); // 显示本人画面
    
    NSString *videoPreset = @"Custom";
    linphone_core_set_video_preset(LC, [videoPreset UTF8String]); //  设置视频格式   视频通话的视频预设  defauit  （Hight FPS） Custom
    
    int bw;
    MSVideoSize vsize;
    switch (2) {
        case 0:
            MS_VIDEO_SIZE_ASSIGN(vsize, 720P);
            // 128 = margin for audio, the BW includes both video and audio
            bw = 1024 + 128;
            break;
        case 1:
            MS_VIDEO_SIZE_ASSIGN(vsize, VGA);
            // no margin for VGA or QVGA, because video encoders can encode the
            // target resulution in less than the asked bandwidth
            bw = 660;
            break;
        case 2:
        default:
            MS_VIDEO_SIZE_ASSIGN(vsize, QVGA);
            bw = 380;
            break;
    }
    linphone_core_set_preferred_video_size(LC, vsize);  // 设置视频画质
    //    if (![videoPreset isEqualToString:@"custom"]) {
    //        [self setInteger:0 forKey:@"video_preferred_fps_preference"]; // 设置FPS
    //        [self setInteger:bw forKey:@"download_bandwidth_preference"]; // 设置频宽
    //    }
    linphone_core_set_preferred_framerate(LC, 0); // 设置FPS
    linphone_core_set_download_bandwidth(LC, bw);  // 设置下载带宽
    linphone_core_set_upload_bandwidth(LC, 100);    // 设置上传带宽
    
}
#pragma mark - 设置音频编码格式
- (void)synchronizeCodecs:(const MSList *)codecs {
    
    PayloadType *pt;
    const MSList *elem;
    
    for (elem = codecs; elem != NULL; elem = elem->next) {
        
        pt = (PayloadType *)elem->data;
        
        //        NSString *sreung = [NSString stringWithFormat:@"%s", pt->mime_type];
        //        NSString *normalBt = [NSString stringWithFormat:@"%d",pt->clock_rate];
        //       if ([sreung isEqualToString:@"G729"]) {
        
        linphone_core_enable_payload_type(LC,pt, YES);
        
        //        }
        //       else
        //        {
        //
        //            linphone_core_enable_payload_type(LC, pt, 0);
        //        }
        
    }
}
#pragma mark - 设置视频编码格式
- (void)synchronizeVideoCodecs:(const MSList *)codecs {
    
    PayloadType *pt;
    const MSList *elem;
    
    for (elem = codecs; elem != NULL; elem = elem->next) {
        
        pt = (PayloadType *)elem->data;
        NSString *sreung = [NSString stringWithFormat:@"%s", pt->mime_type];
        if ([sreung isEqualToString:@"H264"]) {
            
            linphone_core_enable_payload_type(LC, pt, 1);
            
        }else {
            
            linphone_core_enable_payload_type(LC, pt, 0);
        }
    }
}

- (NSMutableArray *)getAllEnableVideoCodec{
    
    NSMutableArray *codeArray = [NSMutableArray array];
    
    PayloadType *pt;
    const MSList *elem;
    
    for (elem =  linphone_core_get_video_codecs(LC); elem != NULL; elem = elem->next) {
        
        pt = (PayloadType *)elem->data;
        
        NSString *sreung = [NSString stringWithFormat:@"%s", pt->mime_type];
        if (linphone_core_payload_type_enabled(LC,pt)) {
            [codeArray addObject:sreung];
        }
    }
    return codeArray;
    
}
- (NSMutableArray *)getAllEnableAudioCodec{
    
    NSMutableArray *codeArray = [NSMutableArray array];
    NSMutableSet *mutableSet = [NSMutableSet set];
    
    PayloadType *pt;
    const MSList *elem;
    
    for (elem =  linphone_core_get_audio_codecs(LC); elem != NULL; elem = elem->next) {
        
        pt = (PayloadType *)elem->data;
        
        NSString *sreung = [NSString stringWithFormat:@"%s", pt->mime_type];
        if (linphone_core_payload_type_enabled(LC,pt)) {
            [codeArray addObject:sreung];
            [mutableSet addObject:sreung];
            
        }
    }
    
    return codeArray;
    
}
#pragma mark - 开启关闭视频编码
- (void)enableVideoCodecWithString:(NSString *)codec enable:(BOOL)enable{
    
    PayloadType *pt;
    const MSList *elem;
    
    for (elem = linphone_core_get_video_codecs(LC); elem != NULL; elem = elem->next) {
        
        pt = (PayloadType *)elem->data;
        NSString *sreung = [NSString stringWithFormat:@"%s", pt->mime_type];
        if ([sreung isEqualToString:codec]) {
            
            linphone_core_enable_payload_type(LC, pt, enable);
        }
    }
}
#pragma mark - 拨打电话
- (void) callPhoneWithPhoneNumber:(NSString *)phone withVideo:(BOOL)video{
    
    LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config(LC);
    if (!cfg) {
        return;
    }
    
    
    
    if (!video) {
        
        LinphoneAddress *addr = [LinphoneManager.instance normalizeSipOrPhoneAddress:phone];
        
        [LinphoneManager.instance call:addr];
        
        if (addr) {
            linphone_address_unref(addr);
        }
        
    }else{
        
        
        LinphoneAddress *addr = linphone_core_interpret_url(LC, [NSString stringWithFormat:@"sip:%@@39.108.234.219:5060",phone].UTF8String);//112.74.13.109:35162  39.108.234.219:5060
        
        LinphoneCallParams *lcallParams = linphone_core_create_call_params(LC, NULL);
        //视频开启
        linphone_call_params_enable_video(lcallParams, YES);
        //发起呼叫指定一个目标linphoneAddress
        linphone_core_invite_address_with_params(LC, addr, lcallParams);
        //linphone地址破坏
        linphone_address_destroy(addr);
        //方法调用参数破坏
        linphone_call_params_destroy(lcallParams);
        
    }
    
    
    
    
    
    
}
- (void)switchCamera{
    
    const char *currentCamId = (char *)linphone_core_get_video_device(LC);
    const char **cameras = linphone_core_get_video_devices(LC);
    const char *newCamId = NULL;
    int i;
    
    for (i = 0; cameras[i] != NULL; ++i) {
        if (strcmp(cameras[i], "StaticImage: Static picture") == 0)
            continue;
        if (strcmp(cameras[i], currentCamId) != 0) {
            newCamId = cameras[i];
            break;
        }
    }
    if (newCamId) {
        // LOGI(@"Switching from [%s] to [%s]", currentCamId, newCamId);
        linphone_core_set_video_device(LC, newCamId);
        LinphoneCall *call = linphone_core_get_current_call(LC);
        if (call != NULL) {
            linphone_call_update(call, NULL);
        }
    }
}
- (void)acceptCall{
    
    LinphoneCall *call = linphone_core_get_current_call(LC);
    if (call) {
        
        [[LinphoneManager instance] acceptCall:call evenWithVideo:YES];
        
    }
}

- (void)hold{
    
}

- (void)unhold{
    
}

- (void)remoteAccount{
    
}

- (void)haveCall{
    
}

- (void)muteMic{
    
}

- (void)enableSpeaker{
    
}

- (void)tabeSnapshot{
    
}

- (void)takePreviewSnapshot{
    
}

- (void)setVideoSize{
    
}

- (void)showVideo{
    
    
}




/**
 挂断电话
 */
- (void)hangUpCall {
    
    LinphoneCore* lc = [LinphoneManager getLc];
    LinphoneCall* currentcall = linphone_core_get_current_call(lc);
    if (linphone_core_is_in_conference(lc) || // In conference
        (linphone_core_get_conference_size(lc) > 0) // Only one conf
        ) {
        linphone_core_terminate_conference(lc);
    } else if(currentcall != NULL) { // In a call
        linphone_core_terminate_call(lc, currentcall);
    } else {
        const MSList* calls = linphone_core_get_calls(lc);
        if (ms_list_size(calls) == 1) { // Only one call
            linphone_core_terminate_call(lc,(LinphoneCall*)(calls->data));
        }
    }
    
    
    NSLog(@"挂断电话成功");
    
}

- (void)setRemoteVieoPreviewWindow:(UIView *)preview{
    
    linphone_core_set_native_preview_window_id(LC, (__bridge void *)(preview));
}

- (void)setNativeVideoPreviewWindow:(UIView *)preview{
    
    linphone_core_set_native_video_window_id(LC, (__bridge void *)(preview));
}
#pragma mark - 清除配置表
- (void)clearProxyConfig {
    
    linphone_core_clear_proxy_config([LinphoneManager getLc]);
    linphone_core_clear_all_auth_info([LinphoneManager getLc]);
}

@end
