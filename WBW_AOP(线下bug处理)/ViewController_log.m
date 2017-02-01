//
//  ViewController_log.m
//  WBW_AOP(线下bug处理)
//
//  Created by 汪博文 on 2017/1/29.
//  Copyright © 2017年 汪博文. All rights reserved.
//

#import "ViewController_log.h"
#import "ViewController.h"



#define INTERCEPTING_ORDER(num) \
NSString *order = [NSString stringWithFormat:@"执行序列:%zd",num]; \

#define INTERCEPTING_BEFORE_CONTENT(content) \
NSMutableString *content = [NSMutableString new]; \
[content appendString:[NSString stringWithFormat:@"%s开始执行.",__func__]] ; \

#define INTERCEPTING_AFTER_CONTENT(content) \
NSMutableString *content = [NSMutableString new]; \
[content appendString:[NSString stringWithFormat:@"%s完成执行.",__func__]] ; \

@implementation ViewController_log {
    NSInteger _num;
    NSMutableDictionary *_dic;
}

//设置被拦截类
INTERCEPT_CLASS(ViewController)
//存日志方法
- (void)logWithContent:(NSString *)content forOrder:(NSString *)order {
    //写日志
    [_dic setValue:content forKey:order];
    //写入路径
    NSString*path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //本地化
    [_dic writeToFile:[path stringByAppendingPathComponent:@"日志.plist"] atomically:YES];
}
//参数安全判断方法
- (NSString *)judgeTheParameterWithFirst:(id)first andSecond:(id)second {
    NSMutableString *judgeMent = [NSMutableString new];
    first == nil ? [judgeMent appendString:@"警告:参数一为空."] : [judgeMent appendString:@"参数一安全."];
    second == nil ? [judgeMent appendString:@"警告:参数二为空."] : [judgeMent appendString:@"参数二安全."];
    return judgeMent;
}

//实现拦截方法
- (void)before_viewDidLoad {
    _dic = [NSMutableDictionary dictionary];
    _num ++;
    INTERCEPTING_ORDER(_num)
    INTERCEPTING_BEFORE_CONTENT(content);

    [self logWithContent:content forOrder:order];
}
- (void)after_viewDidLoad {
    _num++;
    INTERCEPTING_ORDER(_num)
    INTERCEPTING_AFTER_CONTENT(content);
    [self logWithContent:content forOrder:order];
}
//拦截点击登录
- (void)before_touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _num ++;
    INTERCEPTING_ORDER(_num)
    INTERCEPTING_BEFORE_CONTENT(content);
    NSString *judgeMent = [self judgeTheParameterWithFirst:touches andSecond:event];
    [content appendString:judgeMent];
    [self logWithContent:content forOrder:order];
}
- (void)after_touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _num++;
    INTERCEPTING_ORDER(_num)
    INTERCEPTING_AFTER_CONTENT(content);
    NSString *judgeMent = [self judgeTheParameterWithFirst:touches andSecond:event];
    [content appendString:judgeMent];
    [self logWithContent:content forOrder:order];
}
//拦截加密
- (void)before_encryptWithUserName:(NSString *)username password:(NSString *)password {
    _num ++;
    INTERCEPTING_ORDER(_num)
    INTERCEPTING_BEFORE_CONTENT(content);
    NSString *judgeMent = [self judgeTheParameterWithFirst:username andSecond:password];
    [content appendString:judgeMent];
    [self logWithContent:content forOrder:order];
}
- (void)after_encryptWithUserName:(NSString *)username password:(NSString *)password {
    _num++;
    INTERCEPTING_ORDER(_num)
    INTERCEPTING_AFTER_CONTENT(content);
    NSString *judgeMent = [self judgeTheParameterWithFirst:username andSecond:password];
    [content appendString:judgeMent];
    [self logWithContent:content forOrder:order];
}
//拦截登录
- (void)before_loginWithUsername:(NSString *)username password:(NSString *)password {
    _num ++;
    INTERCEPTING_ORDER(_num)
    INTERCEPTING_BEFORE_CONTENT(content);
    NSString *judgeMent = [self judgeTheParameterWithFirst:username andSecond:password];
    [content appendString:judgeMent];
    [self logWithContent:content forOrder:order];
}
- (void)after_loginWithUsername:(NSString *)username password:(NSString *)password {
    _num++;
    INTERCEPTING_ORDER(_num)
    INTERCEPTING_AFTER_CONTENT(content);
    NSString *judgeMent = [self judgeTheParameterWithFirst:username andSecond:password];
    [content appendString:judgeMent];
    [self logWithContent:content forOrder:order];
}


//- (void)before_loadDataWithStr:(NSString *)str {
//    NSString *warning = [NSString new];
//    if (str == nil) {
//        warning = @"警告:参数中有空值";
//    }else {
//        warning = @"参数安全";
//    }
//
//    NSLog(@"before%s%@%@",__func__,str,warning);
//}
//- (void)after_loadDataWithStr:(NSString *)str {
//    NSString *warning = [NSString new];
//    if (str == nil) {
//        warning = @"警告:参数中有空值";
//    }else {
//        warning = @"参数安全";
//    }
//    NSLog(@"after%s%@%@",__func__,str,warning);
//}

@end























