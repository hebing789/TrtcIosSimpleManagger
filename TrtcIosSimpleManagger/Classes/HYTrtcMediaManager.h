//
//  HYTrtcMediaManager.h
//  LiteChat
//
//  Created by 何兵 on 2021/3/14.
//

#import <Foundation/Foundation.h>

/**
 *  网络通话类型
 */
typedef NS_ENUM(NSInteger, HYNetCallMediaType){
  /**
   *  音频通话
   */
  HYNetCallMediaTypeAudio = 1,
  /**
   *  视频通话
   */
  HYNetCallMediaTypeVideo = 2,
};


typedef enum : NSUInteger {
  HYCallControlTypeFeedabck = 1,//收到呼叫请求的反馈，用于被叫告诉主叫可以播放回铃音
  HYCallControlTypeBusyLine ,  //对方正忙
  HYCallControlTypeToAudio ,//暂无视频切换到音频功能
  HYCallControlTypeOpenVideo ,//对方开启了摄像头
  HYCallControlTypeCloseVideo//关闭了摄像头
} HYCallControlType;

static NSString * const kHYUsedBeautyBeforeVideoCall  = @"kHYUsedBeautyBeforeVideoCall";//视频聊天前使用过美颜
static NSString * const kHYVideoBeautyValue           = @"kHYVideoBeautyValue";//美颜磨皮参数
static NSString * const kHYVideoBeautifyWhiteValue         = @"kHYVideoBeautifyWhiteValue";//美颜美白参数
static NSString * const kHYVideoRuddyValue            = @"kHYVideoRuddyValue";//美颜红润参数
static NSString * const kHYVideoFaceType              = @"kHYVideoFaceType";//美型类型
static NSString * const kHYVideoFaceValue             = @"kHYVideoFaceValue";//美颜瘦脸参数
static NSString * const kHYVideoEyeValue              = @"kHYVideoEyeValue";//美颜大眼参数
static NSString * const kHYVideoFilterIndex           = @"kHYVideoFilterIndex";//美颜滤镜参数

@interface HYTrtcMediaManager : NSObject
@property (nonatomic, strong) NSString *currentUseId;
@property (nonatomic, strong) NSMutableSet* allUsersAry;

@property (copy, nonatomic) void (^userInBlock)(NSString *userId,NSMutableSet*allUsers);
@property (copy, nonatomic) void (^userOutBlock)(NSString *userId,NSMutableSet*allUsers);
@property (copy, nonatomic) void (^disConnectBlock)(void);
@property (copy, nonatomic) void (^kickOutRoomBlock)(void);
@property (copy, nonatomic) void (^videoAvailableBlock)(NSString *userId,BOOL available);
@property (nonatomic, assign) HYNetCallMediaType callMediaType;
@property (nonatomic, assign) BOOL isInRoom;
+ (HYTrtcMediaManager *)shareInstance;

//- (void)initTRTCSDK;

- (void)enterRoomWithRoomID:(NSString*)roomID userId:(NSString*)userId role:(NSString*)role callMediaType:(HYNetCallMediaType)callMediaType sdkPara:(NSDictionary*)sdkPara;

- (void)enterRoomWithRoomID:(NSString*)roomID userId:(NSString*)userId role:(NSString*)role callMediaType:(HYNetCallMediaType)callMediaType sdkPara:(NSDictionary*)sdkPara successEnterRoomBlock:(void (^)(void))successEnterRoomBlock failedEnterRoomBlock:(void (^)(void))failedEnterRoomBlock;

- (void)logoutRoom;

- (void)stopLocalPreview;

- (void)stopRemoteView:(NSString *)userId;

- (void)startLocalPreview:(BOOL)frontCamera view:(UIView *)view;

- (void)startRemoteView:(NSString *)userId view:(UIView *)view;

- (void)setDefaultBeautyConfig;

- (void)muteLocalAudio:(BOOL)mute;

- (void)muteRemoteAudio:(NSString *)userId mute:(BOOL)mute;

/**
 * 切换摄像头
 */
- (NSInteger)switchCamera:(BOOL)frontCamera;

- (void)muteLocalVideo:(BOOL)mute;

- (void)setAudioIsSpeaker:(BOOL)isSpeaker;

- (void)clearBlock;
@end

