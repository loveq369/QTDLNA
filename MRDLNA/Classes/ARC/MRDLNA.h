//
//  MRDLNA.h
//  MRDLNA
//
//  Created by MccRee on 2018/5/4.
//

#import <Foundation/Foundation.h>
#import "CLUPnP.h"
#import "CLUPnPDevice.h"

typedef NS_ENUM(NSInteger, DLNAPlayState) {
    DLNAPlayStateUnkown = 0,
    DLNAPlayStatePlaying = 1,
    DLNAPlayStatePause = 2,
    DLNAPlayStateStopped = 3,
    DLNAPlayStateCommpleted = 4,
    DLNAPlayStateError = 5,
};

@protocol DLNAConnentDelegate <NSObject>

@optional
/**
 DLNA局域网搜索设备结果
 @param devicesArray <CLUPnPDevice *> 搜索到的设备
 */
- (void)searchDLNAResult:(NSArray *)devicesArray;

/// DLNA局域网搜索设备出错
- (void)searchDLNAFailue:(NSError *)error;

/// DLNA局域网搜索设备完成
- (void)searchDLNAFinish;

@end

@protocol DLNAPlayDelegate <NSObject>

@optional

///投屏成功开始播放
- (void)dlnaStartPlay;
- (void)dlnaEndPlay;

- (void)dlnaDidChangePlayState:(DLNAPlayState)state;
- (void)dlnaPositionInfo:(CLUPnPAVPositionInfo *)info;

@end

@interface MRDLNA : NSObject

@property(nonatomic, weak) id<DLNAConnentDelegate> connentDelegate;

@property(nonatomic, weak) id<DLNAPlayDelegate> playDelegate;

@property(nonatomic, strong) CLUPnPDevice *device;

@property(nonatomic, copy) NSString *playUrl;

@property(nonatomic, assign) NSInteger searchTime;

@property (nonatomic, assign) BOOL isConnected;

@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSString *referer;

/**
 单例
 */
+ (instancetype)sharedMRDLNAManager;

/**
 搜设备
 */
- (void)startSearch;

- (void)refresSearch;

/**
 停止搜设备
 */
- (void)stopSearch;

/**
 DLNA投屏
 */
- (void)startDLNA;
/**
 DLNA投屏(首先停止)---投屏不了可以使用这个方法
 ** 【流程: 停止 ->设置代理 ->设置Url -> 播放】
 */
- (void)startDLNAAfterStop;

/**
 退出DLNA
 */
- (void)endDLNA;

/**
 播放
 */
- (void)dlnaPlay;

/**
 暂停
 */
- (void)dlnaPause;

///**
// 设置音量 volume建议传0-100之间字符串
// */
//- (void)volumeChanged:(NSString *)volume;

- (void)addVolume;
- (void)reduceVolume;

/**
 设置播放进度 seek单位是秒
 */
- (void)seekChanged:(NSInteger)seek;

/**
 播放切集
 */
- (void)playTheURL:(NSString *)url;
@end
