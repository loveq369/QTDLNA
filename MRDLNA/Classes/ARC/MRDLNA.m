//
//  MRDLNA.m
//  MRDLNA
//
//  Created by MccRee on 2018/5/4.
//

#import "MRDLNA.h"
#import "StopAction.h"

@interface MRDLNA()<CLUPnPServerDelegate, CLUPnPResponseDelegate>

@property(nonatomic, strong) CLUPnPServer *upd;              //MDS服务器
@property(nonatomic, strong) NSMutableArray *dataArray;

@property(nonatomic, strong) CLUPnPRenderer *render;         //MDR渲染器
@property(nonatomic, copy) NSString *volume;
@property(nonatomic, assign) NSInteger seekTime;
@property(nonatomic, assign) BOOL isPlaying;

@end

@implementation MRDLNA

+ (MRDLNA *)sharedMRDLNAManager
{
    static MRDLNA *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.upd = [CLUPnPServer shareServer];
        self.upd.searchTime = 5;
        self.upd.delegate = self;
        self.dataArray = [NSMutableArray array];
    }
    return self;
}


/**
 搜设备
 */
- (void)startSearch
{
    [self.upd start];
}

- (void)refresSearch
{
    [self.upd refresh];
}

- (void)stopSearch
{
    [self.upd stop];
}


/**
 ** DLNA投屏
 */
- (void)startDLNA
{
    [self initCLUPnPRendererAndDlnaPlay];
}
/**
 ** DLNA投屏
 ** 【流程: 停止 ->设置代理 ->设置Url -> 播放】
 */
- (void)startDLNAAfterStop
{
    StopAction *action = [[StopAction alloc]initWithDevice:self.device Success:^{
        [self initCLUPnPRendererAndDlnaPlay];
        
    } failure:^{
        [self initCLUPnPRendererAndDlnaPlay];
    }];
    [action executeAction];
}
/**
 初始化CLUPnPRenderer
 */
- (void)initCLUPnPRendererAndDlnaPlay
{
    self.render = [[CLUPnPRenderer alloc] initWithModel:self.device];
    self.render.delegate = self;
    self.render.userAgent = self.userAgent;
    self.render.referer = self.referer;
    [self.render setAVTransportURL:self.playUrl];
    
    [self.render getVolume];
}
/**
 退出DLNA
 */
- (void)endDLNA
{
    [self.render stop];
}

/**
 播放
 */
- (void)dlnaPlay
{
    [self.render play];
}


/**
 暂停
 */
- (void)dlnaPause
{
    [self.render pause];
}

/**
 设置音量 volume建议传0-100之间字符串
 */
- (void)volumeChanged:(NSString *)volume
{
    self.volume = volume;
    [self.render setVolumeWith:volume];
}

- (void)addVolume
{
    NSString *volume = [NSString stringWithFormat:@"%zd",MIN(self.volume.integerValue+1, 100)];
    NSLog(@"addVolume :%@",volume);
    [self volumeChanged:volume];
}

- (void)reduceVolume
{
    NSString *volume = [NSString stringWithFormat:@"%zd",MAX(self.volume.integerValue-1, 0)];
    NSLog(@"reduceVolume :%@",volume);
    [self volumeChanged:volume];
}

/**
 播放进度条
 */
- (void)seekChanged:(NSInteger)seek
{
    self.seekTime = seek;
    NSString *seekStr = [self timeFormatted:seek];
    [self.render seekToTarget:seekStr Unit:unitREL_TIME];
}


/**
 播放进度单位转换成string
 */
- (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
}

/**
 播放切集
 */
- (void)playTheURL:(NSString *)url
{
    self.playUrl = url;
    [self.render setAVTransportURL:url];
}

#pragma mark -- 搜索协议CLUPnPDeviceDelegate回调
- (void)upnpSearchChangeWithResults:(NSArray<CLUPnPDevice *> *)devices
{
    NSMutableArray *deviceMarr = [NSMutableArray array];
    for (CLUPnPDevice *device in devices) {
        // 只返回匹配到视频播放的设备
        if ([device.uuid containsString:serviceType_AVTransport]) {
            [deviceMarr addObject:device];
        }
    }
    if (self.connentDelegate && [self.connentDelegate respondsToSelector:@selector(searchDLNAResult:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.connentDelegate searchDLNAResult:[deviceMarr copy]];
        });
    }
    self.dataArray = deviceMarr;
}

- (void)upnpSearchErrorWithError:(NSError *)error
{
//    NSLog(@"DLNA_Error======>%@", error);
    if (self.connentDelegate && [self.connentDelegate respondsToSelector:@selector(searchDLNAFailue:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.connentDelegate searchDLNAFailue:error];
        });
    }
}

- (void)upnpDidConnectToService:(CLUPnPServer *)service
{
    if (self.connentDelegate && [self.connentDelegate respondsToSelector:@selector(didConnentToService:)]) {
        [self.connentDelegate didConnentToService:service];
    }
}

- (void)upnpDidNotConnectOnError:(NSError *)error
{
    if (self.connentDelegate && [self.connentDelegate respondsToSelector:@selector(didNotConnentWithError:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.connentDelegate didNotConnentWithError:error];
        });
    }
}

- (void)upnpDidCloseWithError:(NSError *)error
{
    if (self.connentDelegate && [self.connentDelegate respondsToSelector:@selector(didCloseConnentWithError:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.connentDelegate didCloseConnentWithError:error];
        });
    }
}

#pragma mark - CLUPnPResponseDelegate
- (void)upnpSetAVTransportURIResponse
{
    self.isConnected = YES;
    [self.render play];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.playDelegate && [self.playDelegate respondsToSelector:@selector(dlnaStartPlay)]) {
            [self.playDelegate dlnaStartPlay];
        }
    });
}

- (void)upnpGetTransportInfoResponse:(CLUPnPTransportInfo *)info
{
//    NSLog(@"%@ === %@", info.currentTransportState, info.currentTransportStatus);
    if (!([info.currentTransportState isEqualToString:@"PLAYING"] || [info.currentTransportState isEqualToString:@"TRANSITIONING"])) {
        [self.render play];

    }
}

- (void)upnpPlayResponse
{
    [self changePlayState:DLNAPlayStatePlaying];
}

- (void)upnpPauseResponse
{
    [self changePlayState:DLNAPlayStatePause];
}

- (void)upnpStopResponse
{
    self.isConnected = NO;
    
    [self changePlayState:DLNAPlayStateStopped];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.playDelegate && [self.playDelegate respondsToSelector:@selector(dlnaEndPlay)]) {
            [self.playDelegate dlnaEndPlay];
        }
    });
}

- (void)upnpUndefinedResponse:(NSString *)resXML postXML:(NSString *)postXML
{
    CLLog(@"upnpUndefinedResponse :%@ - %@", resXML, postXML);
    [self changePlayState:DLNAPlayStateError];
}

- (void)upnpSeekResponse
{
    
}

- (void)upnpPreviousResponse
{
    
}

- (void)upnpNextResponse
{
    
}

- (void)upnpSetVolumeResponse
{
    NSLog(@"upnpSetVolumeResponse : %@",self.volume);
}

- (void)upnpSetNextAVTransportURIResponse
{
    
}

- (void)upnpGetVolumeResponse:(NSString *)volume
{
    NSLog(@"upnpGetVolumeResponse : %@",volume);
    _volume = volume;
}

- (void)upnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info
{
    if (self.playDelegate && [self.playDelegate respondsToSelector:@selector(dlnaPositionInfo:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playDelegate dlnaPositionInfo:info];
        });
    }
}

- (void)changePlayState:(DLNAPlayState)state
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.playDelegate && [self.playDelegate respondsToSelector:@selector(dlnaDidChangePlayState:)]) {
            [self.playDelegate dlnaDidChangePlayState:state];
        }
    });
}

#pragma mark Set&Get
- (void)setSearchTime:(NSInteger)searchTime
{
    _searchTime = searchTime;
    self.upd.searchTime = searchTime;
}
@end
