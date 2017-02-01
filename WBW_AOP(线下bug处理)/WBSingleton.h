//
//  WBSingleton.h
//  WBW_AOP(线下bug处理)
//
//  Created by 汪博文 on 2017/1/26.
//  Copyright © 2017年 汪博文. All rights reserved.
//



#ifndef WBSingleton_h
#define WBSingleton_h

//定义单例模式类 INTERFACE_SINGLETON(类名)
#undef  INTERFACE_SINGLETON
#define INTERFACE_SINGLETON( __class) \
    - (__class *)sharedInstance; \
    + (__class *)sharedInstance;

//实现单例模式类
#undef  IMPLEMENTATION_SINGLETON
#define IMPLEMENTATION_SINGLETON( __class) \
    - (__class *)sharedInstance \
    { \
        return [__class sharedInstance]; \
    } \
    + (__class *)sharedInstance \
    { \
        static dispatch_once_t once; \
        static __class * __singleton__; \
        dispatch_once( &once, ^{ __singleton__ = [[[self class] alloc] init]; } ); \
        return __singleton__; \
    } \

#endif /* WBSingleton_h */







