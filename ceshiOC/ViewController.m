//
//  ViewController.m
//  ceshiOC
//
//  Created by 吴琼 on 2019/7/29.
//  Copyright © 2019 lcWorld. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //js传过来的参数都包在[]内
    JSContext * context = [[JSContext alloc] init];
    //创建一个类
    /*
     父类
     名字
     属性数组
     */
    context[@"createClass"] = ^(id pares){
        NSString * superClassStr = pares[0];
        NSString * className = pares[1];
        NSArray  * Ivars = [[NSArray alloc]init];
        if ([pares count]>2) {
            Ivars = pares[2];
        }
        
        Class superClass = NSClassFromString(superClassStr);
        Class class = objc_allocateClassPair(superClass, className.UTF8String, 0);
        for (int i = 0; i<Ivars.count; i++) {
            NSArray * ivar = Ivars[i];
            NSString * type = ivar[0];
            NSString * IvarName = ivar[1];
            
            BOOL isSuccess = class_addIvar(class, IvarName.UTF8String, sizeof(NSClassFromString(type)), 0, "@");
        }
        objc_registerClassPair(class);
        
        return className;
    };
//发送消息
    /*
     实例对象
     方法
     参数
     */
    context[@"sendInstenceFunc"] = ^(id pares){
        id Instence = pares[0];
        NSString * func = pares[1];
        
        SEL sel     = NSSelectorFromString(func);
         id myobjc = [self sendMsg:Instence sel:sel pares:pares];
        return myobjc;
    };
    //在主线发送消息
    /*
     实例对象
     方法
     参数
     */
    context[@"sendMainFunc"] = ^(id pares){
        id Instence = pares[0];
        NSString * func = pares[1];
        
        SEL sel     = NSSelectorFromString(func);
        __strong typeof(pares) data = pares;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self sendMsgNoResponse:Instence sel:sel pares:data];
        });
    };
    //设置frame
    /*
     实例对象
     参数{x,y,width,height}
     */
    context[@"setFrame"] = ^(id pares){
        UIView * Instence = pares[0];
        NSDictionary * frame = pares[1];
        Instence.frame = CGRectMake([frame[@"x"] floatValue], [frame[@"y"] floatValue], [frame[@"width"] floatValue], [frame[@"height"] floatValue]);
    };
    //发送消息
    /*
     类名
     方法
     参数
     */
    context[@"sendClassFunc"] = ^(id pares){
        NSString * className = pares[0];
        NSString * func = pares[1];
        
        Class class = NSClassFromString(className);
        SEL sel     = NSSelectorFromString(func);
        id myobjc = [self sendMsg:class sel:sel pares:pares];
        return myobjc;
    };
    //设置属性
    /*
     实例对象
     属性
     参数
     */
    context[@"setIvar"] = ^(id pares){
        
        id objc = pares[0];
        NSString * objcName = pares[1];
        id objcContect = pares[2];
        [objc setValue:objcContect forKey:objcName];
        return objcContect;
    };
    //设置获取属性
    /*
     实例对象
     属性
     */
    context[@"getIvar"] = ^(id pares){
        
        id objc = pares[0];
        NSString * objcName = pares[1];
        SEL sel = NSSelectorFromString(objcName);
        id objc_sub = objc_msgSend(objc,sel);
        return objc_sub;
    };
    //打印值
    //设置获取属性
    /*
     实例对象
     属性
     */
    context[@"log"] = ^(id pares){
        id objc = pares[0];
        NSLog(@"%@",objc);
//        NSString * IvarName = pares[1];
//        NSLog(@"%@",[objc valueForKey:IvarName]);
    };
    //获取rootViewController
    context[@"rootViewController"] = ^(id pares){
        return [UIApplication sharedApplication].delegate.window.rootViewController;
    };
    //加载js文件
    NSString * path = [[NSBundle mainBundle] pathForResource:@"wq" ofType:@"js"];
    NSString * string = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //执行js文件
   [context evaluateScript:string];
    
}
//发送有返回消息
- (id)sendMsg:(id)class sel:(SEL)sel pares:(id)pares{
    
    id myobjc;
    if ([pares count] == 2) {
        myobjc = ((id(*)(id,SEL))objc_msgSend)(class, sel);
    }else if ([pares count] == 3)
    {
        myobjc = ((id(*)(id,SEL,id))objc_msgSend)(class, sel,pares[2]);
    }else if ([pares count] == 4)
    {
        myobjc = ((id(*)(id,SEL,id,id))objc_msgSend)(class, sel,jsToOC(pares[2]),jsToOC(pares[3]));
    }
    else if ([pares count] == 5)
    {
       myobjc = ((id(*)(id,SEL,id,id,id))objc_msgSend)(class, sel,pares[2],pares[3],jsToOC(pares[4]) );
    }
    else if ([pares count] == 6)
    {
        myobjc = ((id(*)(id,SEL,id,id,id,id))objc_msgSend)(class, sel,pares[2],pares[3],pares[4],pares[5]);
    }
    
    return myobjc;
}
//发送无返回消息
- (void)sendMsgNoResponse:(id)class sel:(SEL)sel pares:(id)pares{
    
    if ([pares count] == 2) {
        ((id(*)(id,SEL))objc_msgSend)(class, sel);
    }else if ([pares count] == 3)
    {
        ((id(*)(id,SEL,id))objc_msgSend)(class, sel,pares[2]);
    }else if ([pares count] == 4)
    {
        ((id(*)(id,SEL,id,id))objc_msgSend)(class, sel,pares[2],pares[3]);
    }
    else if ([pares count] == 5)
    {
        ((id(*)(id,SEL,id,id,id))objc_msgSend)(class, sel,pares[2],pares[3],jsToOC(pares[4]) );
    }
    else if ([pares count] == 6)
    {
        ((void(*)(id,SEL,CGRect))objc_msgSend)(class, sel, CGRectMake(2, 2, 22, 2));
    }
}

id jsToOC(id objc){
    if ([objc isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return objc;
}

@end
