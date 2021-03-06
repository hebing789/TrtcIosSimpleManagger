//
//  HYTrtcMediaManager.m
//  LiteChat
//
//  Created by 何兵 on 2021/3/14.
//

#import "HYTrtcMediaManager.h"
#import "TCFilter.h"
#import <TXLiteAVSDK_Professional/TRTCCloud.h>
@interface HYTrtcMediaManager ()<TRTCCloudDelegate>

@property (copy, nonatomic) void (^successEnterRoomBlock)(void);
@property (copy, nonatomic) void (^failedEnterRoomBlock)(void);
@property (nonatomic, strong) AVAudioPlayer *player; //播放提示音
@end

static HYTrtcMediaManager *_instance = nil;
@implementation HYTrtcMediaManager

-(NSMutableSet *)allUsersAry{
  if (_allUsersAry == nil) {
    _allUsersAry = [NSMutableSet new];
  }
  return _allUsersAry;
}

//实例化
+ (HYTrtcMediaManager *)shareInstance {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _instance = [[self alloc] init];
  });
  return _instance;
}


- (instancetype)init {
  self = [super init];
  if(self) {
    [self initTRTCSDK];
  }
  return self;
}

- (void)initTRTCSDK {
  // 创建 trtcCloud 实例
  TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
  trtcCloud.delegate = self;
    [TRTCCloud setLogLevel:TRTCLogLevelError];
  
  
  
}

- (void)configTRTCVideoSDK {
  // 创建 trtcCloud 实例
  TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
  TRTCRenderParams * renderParams = [[TRTCRenderParams alloc] init];
  renderParams.fillMode = TRTCVideoFillMode_Fill;
  [trtcCloud setLocalRenderParams:renderParams];
  TRTCVideoEncParam *videoEncParam = [[TRTCVideoEncParam alloc] init];
  videoEncParam.videoResolution = TRTCVideoResolution_960_540;
  videoEncParam.videoBitrate = 850;
  videoEncParam.videoFps = 15;
  [[TRTCCloud sharedInstance] setVideoEncoderParam:videoEncParam];
  [[TRTCCloud sharedInstance]  startLocalAudio:TRTCAudioQualityDefault];
  //    //主播端设置美颜效果
  [self setDefaultBeautyConfig];
  
}

-(void)setDefaultBeautyConfig{
  TXBeautyManager* beautyManager = [[TRTCCloud sharedInstance] getBeautyManager];
  //从0到1，越大滤镜效果越明显，默认值为0.5。
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  
  //  @"美颜", @"美白", @"红润"
  CGFloat beautyValue = [userDefaults floatForKey:kHYVideoBeautyValue] ? [userDefaults floatForKey:kHYVideoBeautyValue] : 9;
  CGFloat beautyWhiteValue = [userDefaults floatForKey:kHYVideoBeautifyWhiteValue] ? [userDefaults floatForKey:kHYVideoBeautifyWhiteValue] : 9;
  CGFloat redValue = [userDefaults floatForKey:kHYVideoRuddyValue] ? [userDefaults floatForKey:kHYVideoRuddyValue] : 5;
  [beautyManager setBeautyLevel:beautyValue];
  [beautyManager setWhitenessLevel:beautyWhiteValue];
  [beautyManager setRuddyLevel:redValue];
  NSInteger faceType = [userDefaults integerForKey:kHYVideoFaceType] ? [userDefaults floatForKey:kHYVideoFaceType] : 3;
  if (faceType - 400 == 0) {
    [beautyManager setBeautyStyle:TXBeautyStyleSmooth];
  }else if (faceType - 400 == 1) {
    [beautyManager setBeautyStyle:TXBeautyStyleNature];
  } else if (faceType - 400 ==2) {
    [beautyManager setBeautyStyle:TXBeautyStylePitu];
  }else{
    [beautyManager setBeautyStyle:TXBeautyStylePitu];
  }
  
  NSInteger filterIndex = [userDefaults integerForKey:kHYVideoFilterIndex] ? [userDefaults floatForKey:kHYVideoFilterIndex] : 0;
  if (filterIndex == 0) {
    [beautyManager setFilterStrength:0.0];
  }else{
    [beautyManager setFilterStrength:0.5];
  }
  UIImage* image = [self filterImageByMenuOptionIndex:filterIndex];
  [beautyManager setFilter:image];
  
}

- (UIImage*)filterImageByMenuOptionIndex:(NSInteger)index
{
  if (index == 0) {
    return nil;
  }
  TCFilter *filter =  [TCFilterManager defaultManager].allFilters[index-1];
  return [UIImage imageWithContentsOfFile:filter.lookupImagePath];
}

/**
 *停止本地视频采集及预览
 */
- (void)stopLocalPreview{
  TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
  [trtcCloud stopLocalPreview];
}

//停止视频流
- (void)stopRemoteView:(NSString *)userId{
  TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
  [trtcCloud stopRemoteView:userId streamType:TRTCVideoStreamTypeBig];
}

//开启视频流
- (void)startLocalPreview:(BOOL)frontCamera view:(UIView *)view{
  [[TRTCCloud sharedInstance] startLocalPreview:frontCamera view:view];
}

//开启视频流
- (void)startRemoteView:(NSString *)userId view:(UIView *)view{
  TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
  [trtcCloud startRemoteView:userId streamType:TRTCVideoStreamTypeBig view:view];
  //  TRTCRenderParams * renderParams = [[TRTCRenderParams alloc] init];
  //  renderParams.fillMode = TRTCVideoFillMode_Fill;
  //  [trtcCloud setRemoteRenderParams:userId streamType:TRTCVideoStreamTypeBig params:renderParams];
}

/**
 * 4.3 静音/取消静音本地的音频
 
 * @param mute YES：静音；NO：取消静音//关掉本地麦克风
 */
- (void)muteLocalAudio:(BOOL)mute;
{
  TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
  [trtcCloud muteLocalAudio:mute];
}

- (void)muteRemoteAudio:(NSString *)userId mute:(BOOL)mute{
  TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
  [trtcCloud muteRemoteAudio:userId mute:mute];
}

/**
 * 切换摄像头
 */
- (NSInteger)switchCamera:(BOOL)frontCamera{
    TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
    return  [[trtcCloud getDeviceManager]  switchCamera:frontCamera];
}

- (void)muteLocalVideo:(BOOL)mute{
    TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
    [trtcCloud muteLocalVideo:mute];
}

// 音频路由，即声音由哪里输出（扬声器、听筒），默认值：TXAudioRouteSpeakerphone
- (void)setAudioIsSpeaker:(BOOL)isSpeaker{
  TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
  //  TRTCAudioModeSpeakerphone  =   0,   ///< 扬声器
  //  TRTCAudioModeEarpiece      =   1,   ///< 听筒
  if (isSpeaker == YES) {
    [trtcCloud setAudioRoute:TRTCAudioModeSpeakerphone];
  }else{
    [trtcCloud setAudioRoute:TRTCAudioModeEarpiece];
  }
  
}


- (void)startLocalAudio:(TRTCAudioQuality)quality{
  TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
  [trtcCloud startLocalAudio:quality];
}


- (void)stopLocalAudio{
  TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
  [trtcCloud stopLocalAudio];
}

- (void)clearBlock{
    [HYTrtcMediaManager shareInstance].userInBlock = nil;
    [HYTrtcMediaManager shareInstance].userOutBlock = nil;
    [HYTrtcMediaManager shareInstance].disConnectBlock = nil;
    [HYTrtcMediaManager shareInstance].kickOutRoomBlock = nil;
    [HYTrtcMediaManager shareInstance].videoAvailableBlock = nil;
}

#pragma mark - Public

- (void)enterRoomWithRoomID:(NSString*)roomID userId:(NSString*)userId role:(NSString*)role callMediaType:(HYNetCallMediaType)callMediaType sdkPara:(NSDictionary*)sdkPara{
  [self enterRoomWithRoomID:roomID userId:userId role:role callMediaType:callMediaType sdkPara:sdkPara successEnterRoomBlock:nil failedEnterRoomBlock:nil];
}


- (void)enterRoomWithRoomID:(NSString*)roomID userId:(NSString*)userId role:(NSString*)role callMediaType:(HYNetCallMediaType)callMediaType sdkPara:(NSDictionary*)sdkPara successEnterRoomBlock:(void (^)(void))successEnterRoomBlock failedEnterRoomBlock:(void (^)(void))failedEnterRoomBlock {
  self.successEnterRoomBlock = successEnterRoomBlock;
  self.failedEnterRoomBlock = failedEnterRoomBlock;
  if (role.length == 0) {
    role = @"owner";
  }

    TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
    TRTCParams * params = [[TRTCParams alloc] init];
    params.sdkAppId = (UInt32)[[NSString stringWithFormat:@"%@", sdkPara[@"sdkAppId"]] integerValue];
    
    NSString* curUseId = sdkPara[@"userId"];
    if (curUseId.length == 0) {
        curUseId = userId;
    }
    self.currentUseId = curUseId;
    params.userId = curUseId;
    params.userSig = sdkPara[@"userSig"];
    params.roomId =  (UInt32)[[NSString stringWithFormat:@"%@", sdkPara[@"roomId"]] integerValue];
    params.privateMapKey =   sdkPara[@"privateMapKey"];
    self.callMediaType = callMediaType;
    [trtcCloud enterRoom:params appScene:(callMediaType == HYNetCallMediaTypeVideo ? TRTCAppSceneVideoCall : TRTCAppSceneVideoCall)];
  
  
}

- (void)changeRoom {
  
  //  NSString* roomID = @"";
  //  NSString* role = @"owner";
  //  NSString* userId = @"";
  //  if (userId.length == 0) {
  //    userId = [UserWrapper shareUserWrapper].UID;
  //  }
  //  NSDictionary *paramDict = @{
  //    @"userId" : [LocationTool checkNullOrEmpty:userId] ,
  //    @"roomId" : [LocationTool checkNullOrEmpty:roomID],
  //    @"role" : [LocationTool checkNullOrEmpty:role]
  //  };
  //  NSDictionary *realParamDict =  @{ @"params":paramDict,
  //                                    @"url":kHYRTRCgetSignKey};
  //
  //  WeakSelf(self)
  //  [[HYNativeCallRNTool sharedInstance] sendRequestWithTaskName:KHYNativeCallRNNetwrokRequest type:1 param:realParamDict success:^(NSDictionary *message) {
  //    DebugLog(@"%@",message);
  //
  //    NSDictionary *responseDic = message[@"result"];
  //    if (responseDic[@"result"] && [responseDic[@"result"] isKindOfClass:[NSNull class]] == NO && [responseDic[@"result"] integerValue] == 1) {
  //      if ([responseDic[@"data"] isKindOfClass:[NSDictionary class]]) {
  //        NSDictionary* sdkPara = responseDic[@"data"];
  //        TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
  //        TRTCSwitchRoomConfig * params = [[TRTCSwitchRoomConfig alloc] init];
  ////        ERR_SERVER_INFO_ECDH_GET_TINYID                 = -100018,  ///< userSig 校验失败，请检查 TRTCParams.userSig 是否填写正确
  ////        params.sdkAppId = (UInt32)[[NSString stringWithFormat:@"%@", sdkPara[@"sdkAppId"]] integerValue];
  ////        params.userId = sdkPara[@"userId"];
  //        params.userSig = sdkPara[@"userSig"];
  //        params.roomId =  (UInt32)[[NSString stringWithFormat:@"%@", sdkPara[@"roomId"]] integerValue];
  //        params.privateMapKey =   sdkPara[@"privateMapKey"];
  ////        [trtcCloud enterRoom:params appScene:TRTCAppSceneVideoCall];
  //        [trtcCloud switchRoom:params];
  //      }
  //    }else{
  //      [[iToast makeText:responseDic[@"msg"]] show];
  //    }
  //  } failure:^(NSError *error) {
  //    [[iToast makeText:kNetWorkErrorMessage] show];
  //    DebugLog(@"%@",error);
  //  }];
}



- (void)logoutRoom {
  TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
  [trtcCloud exitRoom];
  self.userInBlock = nil;
  self.userOutBlock = nil;
  self.successEnterRoomBlock = nil;
}


- (void)onError:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg extInfo:(nullable NSDictionary*)extInfo{
  if (ERR_ROOM_ENTER_FAIL == errCode) {
    NSLog(@"进房失败[\(errMsg ?? "")]");
    self.isInRoom = NO;
    [self.allUsersAry removeAllObjects];
    //    [[iToast makeText:[NSString stringWithFormat:@"进房失败%@",errMsg]] show];
    //退出房间
    [self logoutRoom];
    if (self.failedEnterRoomBlock != nil) {
      self.failedEnterRoomBlock();
      self.failedEnterRoomBlock= nil;
    }
    if (self.successEnterRoomBlock != nil) {
      self.successEnterRoomBlock= nil;
    }
    
  }
}

/**
 * 1.2 警告回调，用于告知您一些非严重性问题，例如出现了卡顿或者可恢复的解码失败。
 *
 * @param warningCode 警告码
 * @param warningMsg 警告信息
 * @param extInfo 扩展信息字段，个别警告码可能会带额外的信息帮助定位问题
 */
- (void)onWarning:(TXLiteAVWarning)warningCode warningMsg:(nullable NSString *)warningMsg extInfo:(nullable NSDictionary*)extInfo{
  
}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （二）房间事件回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 房间事件回调
/// @{
/**
 * 2.1 已加入房间的回调
 *
 * 调用 TRTCCloud 中的 enterRoom() 接口执行进房操作后，会收到来自 SDK 的 onEnterRoom(result) 回调：
 *
 * - 如果加入成功，result 会是一个正数（result > 0），代表加入房间的时间消耗，单位是毫秒（ms）。
 * - 如果加入失败，result 会是一个负数（result < 0），代表进房失败的错误码。
 * 进房失败的错误码含义请参见[错误码](https://cloud.tencent.com/document/product/647/32257)。
 *
 * @note 在 Ver6.6 之前的版本，只有进房成功会抛出 onEnterRoom(result) 回调，进房失败由 onError() 回调抛出。
 *       在 Ver6.6 及之后改为：进房成功返回正的 result，进房失败返回负的 result，同时进房失败也会有 onError() 回调抛出。
 *
 * @param result result > 0 时为进房耗时（ms），result < 0 时为进房错误码。
 */
- (void)onEnterRoom:(NSInteger)result{
  if (result > 0) {
    self.isInRoom = YES;
    //    [[iToast makeText:[NSString stringWithFormat:@"进房成功，总计耗时%ld ms",(long)result]] show];
    NSLog(@"进房成功，总计耗时%ld ms",(long)result);
    if (self.callMediaType == HYNetCallMediaTypeVideo) {
      [self configTRTCVideoSDK];
    }else{
      TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
      [[trtcCloud getDeviceManager] setSystemVolumeType:TXSystemVolumeTypeAuto];
      [trtcCloud startLocalAudio:TRTCAudioQualityDefault];
    }
    [self.allUsersAry removeAllObjects];
      if (self.currentUseId.length > 0) {
          [self.allUsersAry addObject:self.currentUseId];
      }
    if (self.successEnterRoomBlock != nil) {
      self.successEnterRoomBlock();
      self.successEnterRoomBlock = nil;
      self.failedEnterRoomBlock = nil;
    }
    
  } else {
    //     [[iToast makeText:[NSString stringWithFormat:@"进房失败，错误码:%ld",result]] show];
    NSLog(@"进房失败，错误码:%zd",result);
    //进入房间失败
    self.isInRoom = NO;
    [self.allUsersAry removeAllObjects];
    //退出房间
    [self logoutRoom];
    if (self.failedEnterRoomBlock != nil) {
      self.failedEnterRoomBlock();
      self.failedEnterRoomBlock= nil;
    }
    if (self.successEnterRoomBlock != nil) {
      self.successEnterRoomBlock= nil;
    }
  }
}

/**
 * 2.2 离开房间的事件回调
 *
 * 调用 TRTCCloud 中的 exitRoom() 接口会执行退出房间的相关逻辑，例如释放音视频设备资源和编解码器资源等。
 * 待资源释放完毕，SDK 会通过 onExitRoom() 回调通知到您。
 *
 * 如果您要再次调用 enterRoom() 或者切换到其他的音视频 SDK，请等待 onExitRoom() 回调到来之后再执行相关操作。
 * 否则可能会遇到音频设备（例如 iOS 里的 AudioSession）被占用等各种异常问题。
 *
 * @param reason 离开房间原因，0：主动调用 exitRoom 退房；1：被服务器踢出当前房间；2：当前房间整个被解散。
 */
- (void)onExitRoom:(NSInteger)reason{
  //0：主动调用 exitRoom 退房；1：被服务器踢出当前房间；2：当前房间整个被解散。
  //  [[iToast makeText:[NSString stringWithFormat:@"离开房间原因%zd",reason]] show];
  self.isInRoom = NO;
  [self.allUsersAry removeAllObjects];
  if (self.failedEnterRoomBlock != nil && reason != 0) {
    self.failedEnterRoomBlock();
    self.failedEnterRoomBlock= nil;
  }
  if (self.successEnterRoomBlock != nil) {
    self.successEnterRoomBlock= nil;
  }
  if (reason != 0) {
    if (self.kickOutRoomBlock) {
      self.kickOutRoomBlock();
      self.kickOutRoomBlock = nil;
    }
  }
  
  NSLog(@"离开房间原因%zd",reason);
  //  self.viewTwo.isShow = NO;
  //  self.viewTwo.userId = @"";
  //  self.viewThree.isShow = NO;
  //  self.viewThree.userId = @"";
  //  self.viewFour.isShow = NO;
  //  self.viewFour.userId = @"";
  
}

/**
 * 2.3 切换角色的事件回调
 *
 * 调用 TRTCCloud 中的 switchRole() 接口会切换主播和观众的角色，该操作会伴随一个线路切换的过程，
 * 待 SDK 切换完成后，会抛出 onSwitchRole() 事件回调。
 *
 * @param errCode 错误码，ERR_NULL 代表切换成功，其他请参见[错误码](https://cloud.tencent.com/document/product/647/32257)。
 * @param errMsg  错误信息。
 */
- (void)onSwitchRole:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg{
  
}

/**
 * 2.4 请求跨房通话（主播 PK）的结果回调
 *
 * 调用 TRTCCloud 中的 connectOtherRoom() 接口会将两个不同房间中的主播拉通视频通话，也就是所谓的“主播PK”功能。
 * 调用者会收到 onConnectOtherRoom() 回调来获知跨房通话是否成功，
 * 如果成功，两个房间中的所有用户都会收到 PK 主播的 onUserVideoAvailable() 回调。
 *
 * @param userId 要 PK 的目标主播 userid。
 * @param errCode 错误码，ERR_NULL 代表切换成功，其他请参见[错误码](https://cloud.tencent.com/document/product/647/32257)。
 * @param errMsg  错误信息。
 */
- (void)onConnectOtherRoom:(NSString*)userId errCode:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg{
  
}

/**
 * 2.5 结束跨房通话（主播 PK）的结果回调
 */
- (void)onDisconnectOtherRoom:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg{
  
}

/**
 * 2.6 切换房间 (switchRoom) 的结果回调
 */
- (void)onSwitchRoom:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg{
  if (errCode == ERR_NULL) {
    //    [[iToast makeText:[NSString stringWithFormat:@"切换房间 进房成功"]] show];
    NSLog(@"切换房间 进房成功");
    //    [[TRTCCloud sharedInstance] startLocalPreview:YES view:self.viewOne];
  } else {
    //    [[iToast makeText:[NSString stringWithFormat:@"切换房间进房失败，错误errMsg:%@",errMsg]] show];
    NSLog(@"切换房间进房失败，错误errMsg:%@",errMsg);
  }
}

//                      （三）成员事件回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 成员事件回调
/// @{

/**
 * 3.1 有用户加入当前房间
 *
 * 出于性能方面的考虑，在两种不同的应用场景下，该通知的行为会有差别：
 * - 通话场景（TRTCAppSceneVideoCall 和 TRTCAppSceneAudioCall）：该场景下用户没有角色的区别，任何用户进入房间都会触发该通知。
 * - 直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）：该场景不限制观众的数量，如果任何用户进出都抛出回调会引起很大的性能损耗，所以该场景下只有主播进入房间时才会触发该通知，观众进入房间不会触发该通知。
 *
 *
 * @note 注意 onRemoteUserEnterRoom 和 onRemoteUserLeaveRoom 只适用于维护当前房间里的“成员列表”，如果需要显示远程画面，建议使用监听 onUserVideoAvailable() 事件回调。
 *
 * @param userId 用户标识
 */
- (void)onRemoteUserEnterRoom:(NSString *)userId{
  if ([self.allUsersAry containsObject:userId] == NO) {
    [self.allUsersAry addObject:userId];
    NSLog(@">>>>,allUsersAry:%@",self.allUsersAry);
  }
  if (self.userInBlock) {
    self.userInBlock(userId,self.allUsersAry);
  }
  
}

/**
 * 3.2 有用户离开当前房间
 *
 * 与 onRemoteUserEnterRoom 相对应，在两种不同的应用场景下，该通知的行为会有差别：
 * - 通话场景（TRTCAppSceneVideoCall 和 TRTCAppSceneAudioCall）：该场景下用户没有角色的区别，任何用户的离开都会触发该通知。
 * - 直播场景（TRTCAppSceneLIVE 和 TRTCAppSceneVoiceChatRoom）：只有主播离开房间时才会触发该通知，观众离开房间不会触发该通知。
 *
 * @param userId 用户标识
 * @param reason 离开原因，0 表示用户主动退出房间，1 表示用户超时退出，2 表示被踢出房间。
 */
- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason{
  if ([self.allUsersAry containsObject:userId] == YES) {
    [self.allUsersAry removeObject:userId];
    NSLog(@">>>>,allUsersAry:%@",self.allUsersAry);
  }
  if (self.userOutBlock) {
    self.userOutBlock(userId,self.allUsersAry);
  }
  TRTCCloud* trtcCloud = [TRTCCloud sharedInstance];
  [trtcCloud stopRemoteView:userId streamType:TRTCVideoStreamTypeBig];
  
}

/**
 * 3.3 远端用户是否存在可播放的主路画面（一般用于摄像头）
 *
 * 当您收到 onUserVideoAvailable(userid, YES) 通知时，表示该路画面已经有可用的视频数据帧到达。
 * 此时，您需要调用 startRemoteView(userid) 接口加载该用户的远程画面。
 * 然后，您会收到名为 onFirstVideoFrame(userid) 的首帧画面渲染回调。
 *
 * 当您收到 onUserVideoAvailable(userid, NO) 通知时，表示该路远程画面已被关闭，
 * 可能由于该用户调用了 muteLocalVideo() 或 stopLocalPreview()。
 *
 * @param userId 用户标识
 * @param available 画面是否开启
 */
- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available{
  if ([self.allUsersAry containsObject:userId] == NO) {
    [self.allUsersAry addObject:userId];
    NSLog(@">>>>,allUsersAry:%@",self.allUsersAry);
  }
  if (self.videoAvailableBlock) {
    self.videoAvailableBlock(userId, available);
  }
  
}

/**
 * 3.4 远端用户是否存在可播放的辅路画面（一般用于屏幕分享）
 *
 * @note 显示辅路画面使用的函数是 startRemoteSubStreamView() 而非 startRemoteView()。
 * @param userId 用户标识
 * @param available 屏幕分享是否开启
 */
- (void)onUserSubStreamAvailable:(NSString *)userId available:(BOOL)available{
  
}

/**
 * 3.5 远端用户是否存在可播放的音频数据
 *
 * @param userId 用户标识
 * @param available 声音是否开启
 */
- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available{
  NSLog(@"onUserAudioAvailable");
  if ([self.allUsersAry containsObject:userId] == NO) {
    [self.allUsersAry addObject:userId];
    NSLog(@">>>>,allUsersAry:%@",self.allUsersAry);
  }
}

/**
 * 3.6 开始渲染本地或远程用户的首帧画面
 *
 * 如果 userId == nil，代表开始渲染本地采集的摄像头画面，需要您先调用 startLocalPreview 触发。
 * 如果 userId != nil，代表开始渲染远程用户的首帧画面，需要您先调用 startRemoteView 触发。
 *
 * @note 只有当您调用 startLocalPreivew()、startRemoteView() 或 startRemoteSubStreamView() 之后，才会触发该回调。
 *
 * @param userId 本地或远程用户 ID，如果 userId == nil 代表本地，userId != nil 代表远程。
 * @param streamType 视频流类型：摄像头或屏幕分享。
 * @param width  画面宽度
 * @param height 画面高度
 */
- (void)onFirstVideoFrame:(NSString*)userId streamType:(TRTCVideoStreamType)streamType width:(int)width height:(int)height{
  
}

/**
 * 3.7 开始播放远程用户的首帧音频（本地声音暂不通知）
 *
 * @param userId 远程用户 ID。
 */
- (void)onFirstAudioFrame:(NSString*)userId{
  NSLog(@"onFirstAudioFrame");
}

/**
 * 3.8 首帧本地视频数据已经被送出
 *
 * SDK 会在 enterRoom() 并 startLocalPreview() 成功后开始摄像头采集，并将采集到的画面进行编码。
 * 当 SDK 成功向云端送出第一帧视频数据后，会抛出这个回调事件。
 *
 * @param streamType 视频流类型，主画面、小画面或辅流画面（屏幕分享）
 */
- (void)onSendFirstLocalVideoFrame: (TRTCVideoStreamType)streamType{
  NSLog(@"onSendFirstLocalVideoFrame:");
}

/**
 * 3.9 首帧本地音频数据已经被送出
 *
 * SDK 会在 enterRoom() 并 startLocalAudio() 成功后开始麦克风采集，并将采集到的声音进行编码。
 * 当 SDK 成功向云端送出第一帧音频数据后，会抛出这个回调事件。
 */
- (void)onSendFirstLocalAudioFrame{
  NSLog(@"onSendFirstLocalAudioFrame");
}




/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （四）统计和质量回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 统计和质量回调
/// @{

/**
 * 4.1 网络质量，该回调每2秒触发一次，统计当前网络的上行和下行质量
 *
 * @note userId == nil 代表自己当前的视频质量
 *
 * @param localQuality 上行网络质量
 * @param remoteQuality 下行网络质量
 */
- (void)onNetworkQuality: (TRTCQualityInfo*)localQuality remoteQuality:(NSArray<TRTCQualityInfo*>*)remoteQuality{
  
}

/**
 * 4.2 技术指标统计回调
 *
 * 如果您是熟悉音视频领域相关术语，可以通过这个回调获取 SDK 的所有技术指标。
 * 如果您是首次开发音视频相关项目，可以只关注 onNetworkQuality 回调。
 *
 * @param statistics 统计数据，包括本地和远程的
 * @note 每2秒回调一次
 */
- (void)onStatistics: (TRTCStatistics *)statistics{
  
}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （五）服务器事件回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 服务器事件回调
/// @{

/**
 * 5.1 SDK 跟服务器的连接断开
 */
- (void)onConnectionLost{
  NSLog(@"onConnectionLost:");
  //TODO:自己监控网络对此进行处理
}

/**
 * 5.2 SDK 尝试重新连接到服务器
 */
- (void)onTryToReconnect{
  
}

/**
 * 5.3 SDK 跟服务器的连接恢复
 */
- (void)onConnectionRecovery{
  
}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （六）硬件设备事件回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 硬件设备事件回调
/// @{

/**
 * 6.1 摄像头准备就绪
 */
- (void)onCameraDidReady{
  
}

/**
 * 6.2 麦克风准备就绪
 */
- (void)onMicDidReady{
  
}


/**
 * 6.3 音频路由发生变化（仅 iOS），音频路由即声音由哪里输出（扬声器或听筒）
 *
 * @param route     当前音频路由
 * @param fromRoute 变更前的音频路由
 */
- (void)onAudioRouteChanged:(TRTCAudioRoute)route fromRoute:(TRTCAudioRoute)fromRoute{
  
}


/**
 * 6.4 用于提示音量大小的回调，包括每个 userId 的音量和远端总音量
 *
 * 您可以通过调用 TRTCCloud 中的 enableAudioVolumeEvaluation 接口来开关这个回调或者设置它的触发间隔。
 * 需要注意的是，调用 enableAudioVolumeEvaluation 开启音量回调后，无论频道内是否有人说话，都会按设置的时间间隔调用这个回调;
 * 如果没有人说话，则 userVolumes 为空，totalVolume 为 0。
 *
 * @param userVolumes 所有正在说话的房间成员的音量，取值范围 0 - 100。
 * @param totalVolume 所有远端成员的总音量, 取值范围 0 - 100。
 * @note userId 为 nil 时表示自己的音量，userVolumes 内仅包含正在说话（音量不为 0 ）的用户音量信息。
 */
- (void)onUserVoiceVolume:(NSArray<TRTCVolumeInfo *> *)userVolumes totalVolume:(NSInteger)totalVolume{
  
}


#if !TARGET_OS_IPHONE && TARGET_OS_MAC
/**
 * 6.5 本地设备通断回调
 *
 * @param deviceId 设备 ID
 * @param deviceType 设备类型
 * @param state   0：设备断开；1：设备连接
 */
- (void)onDevice:(NSString *)deviceId type:(TRTCMediaDeviceType)deviceType stateChanged:(NSInteger)state{
  
}


/**
 * 6.6 当前音频采集设备音量变化回调
 *
 * @note 使用 enableAudioVolumeEvaluation（interval>0）开启，（interval == 0）关闭
 *
 * @param volume 音量 取值范围 0 - 100
 * @param muted 当前采集音频设备是否被静音：YES 被静音了，NO 未被静音
 */
- (void)onAudioDeviceCaptureVolumeChanged:(NSInteger)volume muted:(BOOL)muted{
  
}

/**
 * 6.7 当前音频播放设备音量变化回调
 *
 * @note 使用 enableAudioVolumeEvaluation（interval>0）开启，（interval == 0）关闭
 *
 * @param volume 音量 取值范围 0 - 100
 * @param muted 当前音频播放设备是否被静音：YES 被静音了，NO 未被静音
 */
- (void)onAudioDevicePlayoutVolumeChanged:(NSInteger)volume muted:(BOOL)muted{
  
}

#endif

/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                      （七）自定义消息的接收回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 自定义消息的接收回调
/// @{

/**
 * 7.1 收到自定义消息回调
 *
 * 当房间中的某个用户使用 sendCustomCmdMsg 发送自定义消息时，房间中的其它用户可以通过 onRecvCustomCmdMsg 接口接收消息
 *
 * @param userId 用户标识
 * @param cmdID 命令 ID
 * @param seq   消息序号
 * @param message 消息数据
 */
- (void)onRecvCustomCmdMsgUserId:(NSString *)userId cmdID:(NSInteger)cmdID seq:(UInt32)seq message:(NSData *)message{
  
}

/**
 * 7.2 自定义消息丢失回调
 *
 * 实时音视频使用 UDP 通道，即使设置了可靠传输（reliable），也无法确保100@%不丢失，只是丢消息概率极低，能满足常规可靠性要求。
 * 在发送端设置了可靠运输（reliable）后，SDK 都会通过此回调通知过去时间段内（通常为5s）传输途中丢失的自定义消息数量统计信息。
 *
 * @note  只有在发送端设置了可靠传输（reliable），接收方才能收到消息的丢失回调
 * @param userId 用户标识
 * @param cmdID 命令 ID
 * @param errCode 错误码
 * @param missed 丢失的消息数量
 */
- (void)onMissCustomCmdMsgUserId:(NSString *)userId cmdID:(NSInteger)cmdID errCode:(NSInteger)errCode missed:(NSInteger)missed{
  
}

/**
 * 7.3 收到 SEI 消息的回调
 *
 * 当房间中的某个用户使用 sendSEIMsg 发送数据时，房间中的其它用户可以通过 onRecvSEIMsg 接口接收数据。
 *
 * @param userId   用户标识
 * @param message  数据
 */
- (void)onRecvSEIMsg:(NSString *)userId message:(NSData*)message{
  
}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （八）CDN 旁路回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name CDN 旁路转推回调
/// @{

/**
 * 8.1 开始向腾讯云的直播 CDN 推流的回调，对应于 TRTCCloud 中的 startPublishing() 接口
 *
 * @param err 0表示成功，其余值表示失败
 * @param errMsg 具体错误原因
 */
- (void)onStartPublishing:(int)err errMsg:(NSString*)errMsg{
  
}

/**
 * 8.2 停止向腾讯云的直播 CDN 推流的回调，对应于 TRTCCloud 中的 stopPublishing() 接口
 *
 * @param err 0表示成功，其余值表示失败
 * @param errMsg 具体错误原因
 */
- (void)onStopPublishing:(int)err errMsg:(NSString*)errMsg{
  
}

/**
 * 8.3 启动旁路推流到 CDN 完成的回调
 *
 * 对应于 TRTCCloud 中的 startPublishCDNStream() 接口
 *
 * @note Start 回调如果成功，只能说明转推请求已经成功告知给腾讯云，如果目标 CDN 有异常，还是有可能会转推失败。
 */
- (void)onStartPublishCDNStream:(int)err errMsg:(NSString *)errMsg{
  
}

/**
 * 8.4 停止旁路推流到 CDN 完成的回调
 *
 * 对应于 TRTCCloud 中的 stopPublishCDNStream() 接口
 *
 */
- (void)onStopPublishCDNStream:(int)err errMsg:(NSString *)errMsg{
  
}

/**
 * 8.5 设置云端的混流转码参数的回调，对应于 TRTCCloud 中的 setMixTranscodingConfig() 接口
 *
 * @param err 0表示成功，其余值表示失败
 * @param errMsg 具体错误原因
 */
- (void)onSetMixTranscodingConfig:(int)err errMsg:(NSString*)errMsg{
  
}

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      （九）音效回调
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 音效回调
/// @{
/**
 * 播放音效结束回调
 *
 * @param effectId 音效 ID
 * @param code 0 表示播放正常结束；其他表示异常结束
 * @note 该接口已不再维护，推荐使用  TXAudioEffectManager.startPlayMusic 及相关回调
 */
- (void)onAudioEffectFinished:(int) effectId code:(int) code DEPRECATED_ATTRIBUTE{
  
}
/// @}
/////////////////////////////////////////////////////////////////////////////////
//
//                      （十）屏幕分享回调
//
/////////////////////////////////////////////////////////////////////////////////

/// @name 屏幕分享回调
/// @{
/**
 * 10.1 当屏幕分享开始时，SDK 会通过此回调通知
 */
- (void)onScreenCaptureStarted{
  
}

/**
 * 10.2 当屏幕分享暂停时，SDK 会通过此回调通知
 *
 * @param reason 原因，0：用户主动暂停；1：屏幕窗口不可见暂停
 */
- (void)onScreenCapturePaused:(int)reason{
  
}

/**
 * 10.3 当屏幕分享恢复时，SDK 会通过此回调通知
 *
 * @param reason 恢复原因，0：用户主动恢复；1：屏幕窗口恢复可见从而恢复分享
 */
- (void)onScreenCaptureResumed:(int)reason{
  
}

/**
 * 10.4 当屏幕分享停止时，SDK 会通过此回调通知
 *
 * @param reason 停止原因，0：用户主动停止；1：屏幕窗口关闭导致停止
 */
- (void)onScreenCaptureStoped:(int)reason{
  
}


@end
