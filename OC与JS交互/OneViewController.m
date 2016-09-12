//
//  ViewController.m
//  OC与JS交互
//
//  Created by 车 on 16/9/10.
//  Copyright © 2016年 7_______. All rights reserved.
//

#import "OneViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "SecondViewController.h"

@protocol TestJSExport <JSExport>
/*
 OC的函数命名和JS函数命名规则不同 我们可以通过JSExportAs这个宏优化JS中调用的名称
 这个宏只对有参数的selector起作用
 handleFactorialCalculateWithNumber:(NSNumber *)number作为 js方法:calculateForJS的别名*/
JSExportAs
(calculateForJS, - (void)handleFactorialCalculateWithNumber:(NSNumber *)number);
//- (void)calculateForJS:(NSNumber *)number;
//js方法
- (void)pushViewController:(NSString *)view title:(NSString *)title;
- (void)callCamera;

@end

@interface OneViewController ()<UIWebViewDelegate, TestJSExport>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) JSContext *context;//给JavaScript提供运行的上下文环境
@property (nonatomic, strong) UIView *addView;

@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.webView];
    
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"test.html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlString baseURL:nil];
    
}

- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
    }
    return _webView;
}

- (UIView *)addView {
    if (_addView == nil) {
        _addView =[[UIView alloc] initWithFrame:CGRectMake(10, 550, 200, 100)];
        _addView.backgroundColor = [UIColor cyanColor];
    }
    return _addView;
}

#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //将 html的title 设置为controller的title
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    //获取当前页面的url
    NSString *url = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    //这个好像是私有属性 审核时可能被苹果拒绝
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //打印异常,由于JS的异常信息是不会在OC中被直接打印的,所以我们在这里添加打印异常信息
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"exceptionValue --- %@",exceptionValue);
    };
    //以 JSExport 协议关联 native方法
    self.context[@"native"] = self;
    //以 block 形式关联 JavaScript function
    self.context[@"log"] = ^(NSString *str) {
        NSLog(@"%@",str);
    };
    //以 block 形式关联 JavaScript function
    self.context[@"alert"] = ^(NSString *str) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"msg from js" message:str delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alter show];
        });
    };
    //弱引用 避免循环引用
    __block typeof(self) weakSelf = self;
    self.context[@"addSubView"] = ^(NSString *viewName) {
        [weakSelf.view addSubview:weakSelf.addView];
    };
    
    self.context[@"removeSubView"] = ^(NSString *viewName) {
        [weakSelf.addView removeFromSuperview];
    };
    //多参数
    self.context[@"mutiParams"] = ^(NSString *a, NSString *b, NSString *c) {
        NSLog(@"%@ %@ %@",a,b,c);
    };
}

#pragma mark - JSExport Methods
- (void)handleFactorialCalculateWithNumber:(NSNumber *)number{
    NSLog(@"%@", number);
    NSNumber *result = [self calculateFactorialOfNumber:number];
    NSLog(@"%@", result);
    [self.context[@"showResult"] callWithArguments:@[result]];
}

- (void)pushViewController:(NSString *)view title:(NSString *)title{
    Class second = NSClassFromString(view);
    id secondVC = [[second alloc]init];
    ((UIViewController*)secondVC).title = title;
    [self.navigationController pushViewController:secondVC animated:YES];
}

//  假设此方法是在子线程中执行的，线程名sub-thread
- (void)callCamera {
    // 这句假设要在主线程中执行，线程名main-thread
    NSLog(@"callCamera");
    
    // 下面这两句代码最好还是要在子线程sub-thread中执行啊
    JSValue *picCallback = self.context[@"picCallBack"];
    [picCallback callWithArguments:@[@"photos"]];
}

- (void)calculateForJS:(NSNumber *)number {
    NSLog(@"点击了计算阶乘");
    
    JSValue *showResult = self.context[@"showResult"];
    [showResult callWithArguments:@[@"计算阶乘"]];
    
}

#pragma mark - Factorial Method
- (NSNumber *)calculateFactorialOfNumber:(NSNumber *)number{
    NSInteger i = [number integerValue];
    if (i < 0){
        return [NSNumber numberWithInteger:0];
    }
    if (i == 0){
        return [NSNumber numberWithInteger:1];
    }
    NSInteger r = (i * [(NSNumber *)[self calculateFactorialOfNumber:[NSNumber numberWithInteger:(i - 1)]] integerValue]);
    
    return [NSNumber numberWithInteger:r];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.context[@"native"] = nil;
}


@end
