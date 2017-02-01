//
//  ViewController.m
//  WBW_AOP(线下bug处理)
//
//  Created by 汪博文 on 2017/1/26.
//  Copyright © 2017年 汪博文. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];

}
//模拟点击登录
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"用户登录");
    [self encryptWithUserName:@"wbw" password:@"haha"];
}

//模拟加密过程 加密算法为字符串+encrypt
- (void)encryptWithUserName:(NSString *)username password:(NSString *)password {
    NSLog(@"执行加密逻辑");
    username = [NSString stringWithFormat:@"%@+encrypt",username];
    //加密过程中的错误模拟
    password = nil;
    //调用登录
    [self loginWithUsername:username password:password];
}
//模拟登录过程
- (void)loginWithUsername:(NSString *)username password:(NSString *)password {
    NSLog(@"执行登录逻辑");
    //判断
    [username isEqualToString:@"wbw+encrypt"] ? NSLog(@"账号正确") : NSLog(@"账号不正确");
    [username isEqualToString:@"haha+encrypt"] ? NSLog(@"密码正确") : NSLog(@"密码不正确");
}

@end























