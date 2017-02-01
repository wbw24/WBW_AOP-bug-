//
//  WBWInterceptor.m
//  WBW_AOP(线下bug处理)
//
//  Created by 汪博文 on 2017/1/28.
//  Copyright © 2017年 汪博文. All rights reserved.
//

#import "WBWInterceptor.h"
#import "objc/runtime.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

//拦截器名
#define GET_INTERCEPTOR_METHOD_NAME     @"interceptor"
//原始方法名
#define ORIG_METHOD_PREFIX              @"orig_"
//前置拦截方法名
#define INTERCEPTOR_BEFORE_METHOD_NAME  @"before_"
//后置拦截方法名
#define INTERCEPTOR_AFTER_METHOD_NAME   @"after_"

//处理参数方法
//这里我也讲一下
//NSMethodSignature 方法签名
//NSInvocation,和签名类似,但是参数没有限制,NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
//通过签名获取参数数量 NSUInteger argumentCount = [methodSignature numberOfArguments];
//va_list va_start 这个就是对参数进行处理的宏,具体请自行查询
    //下面这个循环就是对所以参数设定位置,index必须从2开始,因为前两个被selector和target占用,,这样我们就插入了参数
//for (int index = 2; index < argumentCount; index++) {
//void *parameter = va_arg(arguments, void *);                                        \
//[invocation setArgument:&parameter atIndex:index];                                  \
//}
#undef AOP_CREATE_INVOCATION
#define AOP_CREATE_INVOCATION( __cmd ) \
NSMethodSignature *methodSignature = [target methodSignatureForSelector:__cmd];          \
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];\
va_list arguments;                                                                      \
va_start(arguments, __cmd);                                                              \
NSUInteger argumentCount = [methodSignature numberOfArguments];                         \
for (int index = 2; index < argumentCount; index++) {                                   \
void *parameter = va_arg(arguments, void *);                                        \
[invocation setArgument:&parameter atIndex:index];                                  \
}                                                                                       \
va_end(arguments);

//执行before方法
void execBeforeMethod(id target,SEL _cmd,NSInvocation *invocation) {
    //方法名
    NSString *methodName = NSStringFromSelector(_cmd);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    //获取拦截者类
    id interceptor = [target performSelector:@selector(interceptor)];
#pragma clang diagnostic pop

    if(interceptor != nil) {
        SEL beforeMethodSel = NSSelectorFromString([NSString stringWithFormat:@"%@%@",INTERCEPTOR_BEFORE_METHOD_NAME,methodName]);
        if([interceptor respondsToSelector:beforeMethodSel]) {
            invocation.selector = beforeMethodSel;
            invocation.target = interceptor;
            [invocation invoke];
        }
    }
}

//执行after方法
void execAfterMethod(id target, SEL _cmd, NSInvocation *invocation) {
    NSString *methodName = NSStringFromSelector(_cmd);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    id interceptor = [target performSelector:@selector(interceptor)];
#pragma clang diagnostic pop

    //callback after
    if(interceptor != nil) {
        SEL afterMethodSel = NSSelectorFromString([NSString stringWithFormat:@"%@%@",INTERCEPTOR_AFTER_METHOD_NAME,methodName]);
        if([interceptor respondsToSelector:afterMethodSel]) {
            invocation.selector = afterMethodSel;
            invocation.target = interceptor;
            [invocation invoke];
        }
    }
}

//执行原始方法
void execOrigMethod(id target, SEL _cmd, NSInvocation *invocation) {
    SEL origSEL = NSSelectorFromString([NSString stringWithFormat:@"%@%@",ORIG_METHOD_PREFIX,NSStringFromSelector(_cmd)]);
    invocation.selector = origSEL;
    invocation.target = target;
    [invocation invoke];
}


/**
 *  无返回值调用
 *
 *  @param target 调用目标
 *  @param _cmd   调用方法
 *  @param ...    参数
 */
void vCallbackDynamicMethodIMP(id target,SEL _cmd,...) {
    //处理方法的参数
    AOP_CREATE_INVOCATION(_cmd);
    execBeforeMethod(target, _cmd, invocation);
    execOrigMethod(target,_cmd,invocation);
    execAfterMethod(target, _cmd, invocation);
}
/**
 *  OC对象返回值调用
 *
 *  @param target 调用目标
 *  @param _cmd   调用方法
 *  @param ...    参数
 *
 *  @return 返回OC对象
 */
id callbackDynamicMethodIMP(id target,SEL _cmd,...) {
    //处理参数
    AOP_CREATE_INVOCATION(_cmd);
    id returnValue = nil;
    execBeforeMethod(target, _cmd, invocation);
    execOrigMethod(target,_cmd,invocation);
    [invocation getReturnValue:&returnValue];
    execAfterMethod(target, _cmd, invocation);
    return returnValue;
}


//宏定义不同类型的返回值,调用
#undef AOP_DEF_TYPE_FUNCTION
#define AOP_DEF_TYPE_FUNCTION( __type__ , __funcationName__ )                   \
__type__ __funcationName__(id target,SEL _cmd,...) {                            \
AOP_CREATE_INVOCATION(_cmd);                                                \
execBeforeMethod(target, _cmd, invocation);                                 \
execOrigMethod(target,_cmd,invocation);                                     \
__type__ returnValue;                                                       \
[invocation getReturnValue:&returnValue];                                   \
execAfterMethod(target, _cmd, invocation);                                  \
return returnValue;                                                         \
}

AOP_DEF_TYPE_FUNCTION(char,CALLBACK_FUNCTION_NAME_char)

AOP_DEF_TYPE_FUNCTION(unsigned char,CALLBACK_FUNCTION_NAME_unsigned_char)

AOP_DEF_TYPE_FUNCTION(signed char,CALLBACK_FUNCTION_NAME_signed_char)

AOP_DEF_TYPE_FUNCTION(unichar,CALLBACK_FUNCTION_NAME_unichar)

AOP_DEF_TYPE_FUNCTION(short,CALLBACK_FUNCTION_NAME_short)

AOP_DEF_TYPE_FUNCTION(unsigned short,CALLBACK_FUNCTION_NAME_unsigned_short)

AOP_DEF_TYPE_FUNCTION(signed short,CALLBACK_FUNCTION_NAME_signed_short)

AOP_DEF_TYPE_FUNCTION(int, CALLBACK_FUNCTION_NAME_int)

AOP_DEF_TYPE_FUNCTION(unsigned int, CALLBACK_FUNCTION_NAME_unsigned_int)

AOP_DEF_TYPE_FUNCTION(signed int, CALLBACK_FUNCTION_NAME_signed_int)

AOP_DEF_TYPE_FUNCTION(long, CALLBACK_FUNCTION_NAME_long)

AOP_DEF_TYPE_FUNCTION(unsigned long, CALLBACK_FUNCTION_NAME_unsigned_long)

AOP_DEF_TYPE_FUNCTION(signed long,CALLBACK_FUNCTION_NAME_signed_long)

AOP_DEF_TYPE_FUNCTION(long long, CALLBACK_FUNCTION_NAME_long_long)

AOP_DEF_TYPE_FUNCTION(unsigned long long, CALLBACK_FUNCTION_NAME_unsigned_long_long)

AOP_DEF_TYPE_FUNCTION(signed long long, CALLBACK_FUNCTION_NAME_signed_long_long)

AOP_DEF_TYPE_FUNCTION(NSInteger,CALLBACK_FUNCTION_NAME_NSInteger)

AOP_DEF_TYPE_FUNCTION(NSUInteger, CALLBACK_FUNCTION_NAME_NSUInteger)

AOP_DEF_TYPE_FUNCTION(float, CALLBACK_FUNCTION_NAME_float)

AOP_DEF_TYPE_FUNCTION(CGFloat, CALLBACK_FUNCTION_NAME_CGFloat)

AOP_DEF_TYPE_FUNCTION(double, CALLBACK_FUNCTION_NAME_double)

AOP_DEF_TYPE_FUNCTION(BOOL,CALLBACK_FUNCTION_NAME_BOOL)

AOP_DEF_TYPE_FUNCTION(CGRect,CALLBACK_FUNCTION_NAME_CGRect)

AOP_DEF_TYPE_FUNCTION(CGPoint,CALLBACK_FUNCTION_NAME_CGPoint)

AOP_DEF_TYPE_FUNCTION(CGSize,CALLBACK_FUNCTION_NAME_CGSize)

AOP_DEF_TYPE_FUNCTION(UIEdgeInsets,CALLBACK_FUNCTION_NAME_UIEdgeInsets)

AOP_DEF_TYPE_FUNCTION(UIOffset,CALLBACK_FUNCTION_NAME_UIOffset)

AOP_DEF_TYPE_FUNCTION(CGVector,CALLBACK_FUNCTION_NAME_CGVector)

@interface WBWInterceptor (PRIVATE)
- (Class)interceptorClassForInterceptedClass:(Class)interceptedClass;
@end


typedef id (*InterceptedClassIMP) (id, SEL);
//动态添加拦截器的方法
id getInterceptorDynamicMethodIMP(id interceptedInstance, SEL _cmd) {
    
    id interceptor = objc_getAssociatedObject(interceptedInstance, kWBWInterceptorPropertyKey);
    if(interceptor == nil) {
        //查询拦截者字典,根据被拦截者key找到拦截者
        Class interceptorClass = [[WBWInterceptor sharedInstance] interceptorClassForInterceptedClass:[interceptedInstance class]];
        //安全判断,拦截者存在
        if(interceptorClass != nil) {
            interceptor = [[interceptorClass alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            //定义被拦截者中的宏set方法
            SEL setInterceptedInstanceSel = @selector(setInterceptedInstance:);
#pragma clang diagnostic pop
            
            //安全判断,判断是否实现了set方法
            if([interceptor respondsToSelector:setInterceptedInstanceSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                //将拦截者对象和被拦截者对象动态关联起来
                [interceptor performSelector:setInterceptedInstanceSel withObject:interceptedInstance];
#pragma clang diagnostic pop
            }
            //将当前的拦截者和被拦截者动态关联起来
            objc_setAssociatedObject(interceptedInstance, kWBWInterceptorPropertyKey, interceptor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    //返回拦截者
    return interceptor;
}


@implementation WBWInterceptor {
    //用来存放拦截者信息的字典,谁是拦截者,谁是被拦截者
    NSMutableDictionary     *_interceptorClasses;
}
//单例实现
IMPLEMENTATION_SINGLETON(WBWInterceptor)

//主入口,安装
+ (void)setup {
    [WBWInterceptor sharedInstance];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _interceptorClasses = [NSMutableDictionary dictionary];
        //初始化拦截者类
        [self setupInterceptedClasses];
    }
    return self;
}
//提供查询的方法
- (Class)interceptorClassForInterceptedClass:(Class)interceptedClass {
    return [_interceptorClasses objectForKey:NSStringFromClass(interceptedClass)];
}

//初始化所有注入的类
- (void)setupInterceptedClasses {
    //查询所有定义注入的类,就是所有遵循协议的类,拦截者类
    NSArray *interceptedClasses = [self queryInterceptorClasses];
    //遍历所有拦截者类
    [interceptedClasses enumerateObjectsUsingBlock:^(id  _Nonnull cls, NSUInteger idx, BOOL * _Nonnull stop) {
        //安装拦截器
        [self setupInterceptor:cls];
    }];
}

//获取所有的拦截者并返回拦截列表
- (NSArray *)queryInterceptorClasses {
    NSMutableArray *interceptorClasses = [NSMutableArray array];
    int numClasses;
    Class *classes = NULL;
    classes = NULL;
    //通过objc_getClassList函数获取所有注册的类,文档提供的方法就是这么写的
    numClasses = objc_getClassList(NULL, 0);
    
    if (numClasses > 0) {
        //拦截者遵循的协议
        Protocol *aopProtocol = @protocol(WBWInterceptorProtocol);
        //获取一个所有类的存储空间,里面放了所有的类
        classes = (Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        //遍历所有类
        for (NSInteger i = 0; i < numClasses; i++) {
            //每一个类
            Class cls = classes[i];
            //遍历当前类本身和本身的所有父类
            for (Class thisClass = cls; nil != thisClass; thisClass = class_getSuperclass(thisClass)) {
                //如果这个类遵循了协议,便是拦截者,便添加到拦截者列表中
                if (class_conformsToProtocol(thisClass, aopProtocol)) {
                    [interceptorClasses addObject:cls];
                }
            }
        }
        //释放,这是规矩
        free(classes);
    }
    //返回拦截者列表
    return interceptorClasses;
}


//这个方法,会在拦截者中找到被拦截者,同时为被拦截者安装拦截器
- (void)setupInterceptor:(Class)cls {
    //拦截者类中有一个宏定义方法 能够返回被拦截者类的方法
    //由于方法是宏定义出来的,所以这里会有一个警告:没有实现interceptedClass这个方法的警告,本人有强迫症,所以就用宏来忽略该警告了
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL getInterceptedClassSel = @selector(interceptedClass);
#pragma clang diagnostic pop
    
    //获得这个类方法,返回被拦截者类的类方法
    Method getInterceptedClassMethod = class_getClassMethod(cls, getInterceptedClassSel);
    //安全判断,如果拦截者没有去拦截,就返回
    if (getInterceptedClassMethod == NULL) {
        return;
    }
    //现在我们要知道被拦截者到底是什么类,我在上面定义了一个InterceptedClassIMP函数类型,定义一个这个类型的变量用来得到被拦截者类的类
    InterceptedClassIMP getInterceptedClassMethodIMP = (InterceptedClassIMP)method_getImplementation(getInterceptedClassMethod);
    //这里我们终于拿到了被拦截者类,现在要给被拦截者类安装拦截器,实现拦截功能
    Class interceptedClass = getInterceptedClassMethodIMP(cls,getInterceptedClassSel);
    //为成员变量_interceptorClasses注册新的拦截者信息
    [self registerInterceptorClass:cls forInterceptedClass:interceptedClass];
    //为被拦截的类安装拦截器
    [self setupInterceptorClass:cls forInterceptedClass:interceptedClass];
    //实现拦截器功能,拦截目标类,替换成自己的方法
    [self interceptedMethodsWithInterceptedClass:interceptedClass interceptor:cls];
    
}
/**
 *  为成员变量_interceptorClasses注册新的拦截者信息
 *
 *  @param interceptor      拦截者类
 *  @param interceptedClass 被拦截的类
 *  用一个成员变量字典成对保存拦截者,被拦截者,方便以后调用
 */
- (void)registerInterceptorClass:(Class)interceptor forInterceptedClass:(Class)interceptedClass {
    //kvc去赋值,拦截者字典中,被拦截者类:interceptedClass,拦截者是:interceptor
    [_interceptorClasses setObject:interceptor forKey:NSStringFromClass(interceptedClass)];
}
/**
 *  为被拦截的类安装拦截器
 *
 *  @param interceptedClass 被拦截者
 */
- (void)setupInterceptorClass:(Class)interceptor forInterceptedClass:(Class)interceptedClass {
    //利用运行时,动态添加一个方法,这个就是拦截器
    //这个方法我详细讲一下,现在我们有了被拦截的类,我们肯定要给它动态添加一个方法,这个方法就是拦截器
    //class_addMethod(Class cls, SEL name, IMP imp, const char *types)
    //cls：被添加方法的类
    //name：可以理解为方法名，我们这里用了一个宏定义GET_INTERCEPTOR_METHOD_NAME @"interceptor"
    //imp：实现这个方法的函数
    //types：一个定义该函数返回值类型和参数类型的字符串 根据该函数的格式(id)getInterceptorDynamicMethodIMP(<#id interceptedInstance#>, <#SEL _cmd#>),types应该写成"@@:",这个不理解自己查一下吧
    class_addMethod(interceptedClass, NSSelectorFromString(GET_INTERCEPTOR_METHOD_NAME), (IMP)getInterceptorDynamicMethodIMP, "@@:");
}

/**
 *  通过拦截器拦截目标类 核心方法
 *
 *  @param interceptedClass 被拦截者
 *  @param interceptor      拦截者
 */
- (void)interceptedMethodsWithInterceptedClass:(Class)interceptedClass interceptor:(Class)interceptor {
    //终于到拦截器的写法了
    //利用运行时,找到被拦截者里面的所有方法
    NSArray *methods = [self methodsForClass:interceptedClass];
    //遍历被拦截者中的所有方法
    [methods enumerateObjectsUsingBlock:^(NSString* methodName, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![methodName isEqualToString:@"interceptor"]) {
            //定义before方法
            SEL beforeMethodSel = NSSelectorFromString([NSString stringWithFormat:@"%@%@",INTERCEPTOR_BEFORE_METHOD_NAME,methodName]);
            //定义after方法
            SEL afterMethodSel  = NSSelectorFromString([NSString stringWithFormat:@"%@%@",INTERCEPTOR_AFTER_METHOD_NAME, methodName]);
            //从拦截者中获取before方法
            Method beforeMethod = class_getInstanceMethod(interceptor, beforeMethodSel);
            //从拦截者中获取after方法
            Method afterMethod  = class_getInstanceMethod(interceptor, afterMethodSel);
            //安全判断,看拦截者是否实现了这两个方法
            if (beforeMethod || afterMethod) {
                //被拦截的方法的原始名
                SEL originalMethodSel = NSSelectorFromString(methodName);
                //新的名字
                SEL newOriginalMethodSel = NSSelectorFromString([NSString stringWithFormat:@"%@%@", ORIG_METHOD_PREFIX, methodName]);
                
                Method originalMethod = class_getInstanceMethod(interceptedClass, originalMethodSel);
                IMP origMethodIMP = class_getMethodImplementation(interceptedClass, originalMethodSel);
                //为被拦截者类动态添加拦截方法
                class_addMethod(interceptedClass, newOriginalMethodSel, origMethodIMP, method_getTypeEncoding(originalMethod));
                //方法签名,NSMethodSignature,是对方法的参数,返回类型进行封装
                NSMethodSignature *sig = [interceptedClass instanceMethodSignatureForSelector:originalMethodSel];
                //利用方法签名获得返回类型
                const char *returnType = sig.methodReturnType;
                
                //根据返回值不同,规定不同的方法
                if(!strcmp(returnType, @encode(void)) ) {//返回值为空
                    //将被拦截者类中的被拦截方法替换成我们想要的方法
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)vCallbackDynamicMethodIMP ,method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(id))) {//返回值为对象
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)callbackDynamicMethodIMP ,method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(char))) {//返回值为char
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_char ,method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(unsigned char))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_unsigned_char,method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(signed char))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_signed_char,method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(unichar))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_unichar, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(short))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_short, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(unsigned short))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_unsigned_short, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(signed short))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_signed_short, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(int))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_int, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(unsigned int))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_unsigned_int, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(signed int))){
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_signed_int, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(long))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_long, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(unsigned long))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_unsigned_long, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(signed long))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_signed_long, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(long long))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_long_long, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(unsigned long long))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_unsigned_long_long, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(signed long long))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_signed_long_long, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(NSInteger))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_NSInteger, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(NSUInteger))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_NSUInteger, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(float))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_float, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(CGFloat))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_CGFloat, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(double))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_double, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(BOOL))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_BOOL, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(CGRect))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_CGRect, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(CGPoint))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_CGPoint, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(CGSize))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_CGSize, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(UIEdgeInsets))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_UIEdgeInsets, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(UIOffset))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_UIOffset, method_getTypeEncoding(originalMethod));
                } else if(!strcmp(returnType, @encode(CGVector))) {
                    class_replaceMethod(interceptedClass, originalMethodSel, (IMP)CALLBACK_FUNCTION_NAME_CGVector, method_getTypeEncoding(originalMethod));
                } else {
                    NSLog(@"not support return type ( %s ) in Class %@ => %@",method_getTypeEncoding(originalMethod),interceptedClass,methodName);
                }            }
        }
    }];
}
/**
 *  运用运行时通过类获取所有方法
 *
 *  @param cls 类
 *
 *  @return 返回方法名的集合
 */
- (NSArray *)methodsForClass:(Class)cls {
    NSMutableArray *methods = [NSMutableArray array];
    //安全判断
    if (cls == nil) return methods;
    uint methodListCount = 0;
    Method *pArrMethods = class_copyMethodList(cls, &methodListCount);
    //安全判断
    if (pArrMethods != NULL && methodListCount > 0) {
        for (int i = 0; i < methodListCount; i++) {
            SEL name = method_getName(pArrMethods[i]);
            NSString *methodName = [NSString stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
            [methods addObject:methodName];
        }
        free((void *)pArrMethods);
    }
    return methods;
}


@end























