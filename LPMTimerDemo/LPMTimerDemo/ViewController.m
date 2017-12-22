//
//  ViewController.m
//  LPMTimerDemo
//
//  Created by 金龙潘 on 2017/12/22.
//  Copyright © 2017年 金龙潘. All rights reserved.
//

#import "ViewController.h"
#import "LPMTimer.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (nonatomic, strong) LPMTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self recreateClicked:nil];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)recreateClicked:(id)sender {
    NSLog(@"create Timer!");
    static NSInteger i;
    __weak typeof(self) weakSelf = self;
    LPMTimerBlock block = ^(LPMTimer *timer){
        typeof(self) strongSelf = weakSelf;
        strongSelf.label.text = [NSString stringWithFormat:@"hahahaha %zd",i];
        NSLog(@"%@",[NSThread currentThread]);
        NSLog(@"timer: %zd",i++);
    };
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
//        [LPMTimer firedTimerWithInterval:1 repeat:NO block:block];
//    });
    self.timer = [LPMTimer timerWithInterval:3 repeat:YES block:block];
    
    
}
- (IBAction)fireClicked:(id)sender {
    [self.timer fire];
    NSLog(@"fired");
}
- (IBAction)invalidateClicked:(id)sender {
    NSLog(@"%@",self.timer.isValid?@"valid":@"invalid");
    [self.timer invalidate];
    NSLog(@"invalidated");
    NSLog(@"%@",self.timer.isValid?@"valid":@"invalid");
}
- (IBAction)pauseClicked:(id)sender {
    if (self.timer.status == LPMTimerFiring) {
        [self.timer pause];
        NSLog(@"paused");
        [self.pauseButton setTitle:@"Resume" forState:UIControlStateNormal];
    }else if (self.timer.status == LPMTimerPaused) {
        [self.timer resume];
        NSLog(@"resumed");
        [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}


@end
