//
//  RootViewController.m
//  OC与JS交互
//
//  Created by 车 on 16/9/10.
//  Copyright © 2016年 7_______. All rights reserved.
//

#import "RootViewController.h"
#import "OneViewController.h"
@interface RootViewController ()



@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    OneViewController *one = [[OneViewController alloc] init];
    [self.navigationController pushViewController:one animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
