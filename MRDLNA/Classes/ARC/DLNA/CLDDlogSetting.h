//
//  CLDDlogSetting.h
//  Pods
//
//  Created by sillker on 2022/7/6.
//

#ifndef CLDDlogSetting_h
#define CLDDlogSetting_h


#import "CocoaLumberjack.h"

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelInfo;
#endif

#endif /* CLDDlogSetting_h */
