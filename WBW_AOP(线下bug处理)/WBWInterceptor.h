//
//  WBWInterceptor.h
//  WBW_AOP(线下bug处理)
//
//  Created by 汪博文 on 2017/1/28.
//  Copyright © 2017年 汪博文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "objc/runtime.h"
//单例头文件
#import "WBSingleton.h"

//两个key的宏定义
#define kWBWInterceptorPropertyKey           @"kWBWInterceptorPropertyKey"
#define kWBWInterceptedInstancePropertyKey   @"kWBWInterceptedInstancePropertyKey"

//被拦截者方法宏,让拦截者添加被拦截者
/**
 1.第一个方法,返回被拦截者的类
 2.set方法 运行时动态的为拦截者类关联一个被拦截者类属性,类似set方法
 3.get方法 运行时动态的为拦截者类关联一个被拦截者属性,类似get方法
 */
#undef INTERCEPT_CLASS
#define INTERCEPT_CLASS( __class ) \
+ (Class)interceptedClass \
{ \
return [__class class]; \
} \
- (void)setInterceptedInstance:(__class *)instance \
{ \
objc_setAssociatedObject(self, kWBWInterceptedInstancePropertyKey, instance, OBJC_ASSOCIATION_ASSIGN);\
} \
- (__class *)interceptedInstance \
{ \
id interceptedInstance = objc_getAssociatedObject(self, kWBWInterceptedInstancePropertyKey); \
return (__class *)interceptedInstance;\
} \



//拦截者协议,安装的时候会用运行时遍历所有的类,只有遵循了拦截者协议的类才能成为拦截者
@protocol WBWInterceptorProtocol <NSObject>

@end


@interface WBWInterceptor : NSObject
//单例声明
INTERFACE_SINGLETON(WBWInterceptor)

//主入口,安装
+ (void)setup;

@end
























