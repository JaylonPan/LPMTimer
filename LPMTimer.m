//
//  LPMTimer.m
//  TestHookUtils
//
//  Created by 金龙潘 on 2017/12/21.
//  Copyright © 2017年 金龙潘. All rights reserved.
//

#import "LPMTimer.h"

@interface LPMTimer (){
    CFRunLoopTimerRef _timerRef;
    CFRunLoopRef _timerRunloop;
}
@property (nonatomic, strong) LPMTimer *selfForNotRepeatTimer;
@property (nonatomic, copy) LPMTimerBlock block;
@property (nonatomic, assign, getter=isRepeat) BOOL repeat;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, assign) BOOL scheduleRightNow;
@property (nonatomic, strong) NSDate *lastScheduleDate;
@property (nonatomic, assign) NSTimeInterval timeForResume;
@property (assign ) LPMTimerStatus status;
@end
@implementation LPMTimer
- (void)dealloc {
    [self invalidate];
    if (_timerRunloop) {
        CFRunLoopRemoveTimer(_timerRunloop, _timerRef, kCFRunLoopDefaultMode);
    }
    CFRelease(_timerRef);
    _timerRef = nil;
    _timerRunloop = nil;
//    NSLog(@"LPMTimer deallocated!");
}
- (instancetype)initWithInterval:(NSTimeInterval)interval repeat:(BOOL)repeat rightNow:(BOOL)rightNow block:(LPMTimerBlock)block {
    if (self = [super init]) {
        self.timeInterval = interval;
        self.scheduleRightNow = rightNow;
        self.repeat = repeat;
        self.block = block;
        CFAbsoluteTime time = CFDateGetAbsoluteTime((CFDateRef)[NSDate dateWithTimeIntervalSinceNow:rightNow ?0:interval]);
        _timerRef = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, time, interval, 0, 0, ^(CFRunLoopTimerRef timer) {
            self.lastScheduleDate = [NSDate date];
            self.block(self);
            if (!repeat) {
                [self invalidate];
            }
        });
        self.status = LPMTimerPreparedToFire;
    }
    return self;
}

- (instancetype)initWithInterval:(NSTimeInterval)interval repeat:(BOOL)repeat block:(LPMTimerBlock)block {
    return [self initWithInterval:interval repeat:repeat rightNow:NO block:block];
}

+ (instancetype)timerWithInterval:(NSTimeInterval)interval repeat:(BOOL)repeat block:(LPMTimerBlock)block {
    return [self timerWithInterval:interval repeat:repeat rightNow:NO block:block];
}

+ (instancetype)timerScheduleRightNowWithTimeInterval:(NSTimeInterval)interval repeat:(BOOL)repeat block:(LPMTimerBlock)block {
    return [self timerWithInterval:interval repeat:repeat rightNow:YES block:block];
}

+ (instancetype)timerWithInterval:(NSTimeInterval)interval repeat:(BOOL)repeat rightNow:(BOOL)rightNow  block:(LPMTimerBlock)block {
    return [[LPMTimer alloc]initWithInterval:interval repeat:repeat rightNow:rightNow block:block];
}

+ (instancetype)firedTimerWithInterval:(NSTimeInterval)interval
                                repeat:(BOOL)repeat
                              rightNow:(BOOL)rightNow
                                 block:(LPMTimerBlock)block {
    LPMTimer *timer = [LPMTimer timerWithInterval:interval repeat:repeat rightNow:rightNow block:block];
    [timer fire];
    return timer;
}
+ (instancetype)firedTimerWithInterval:(NSTimeInterval)interval repeat:(BOOL)repeat block:(LPMTimerBlock)block {
    return [self firedTimerWithInterval:interval repeat:repeat rightNow:NO block:block];
}
+ (instancetype)firedTimerScheduleRightNowWithTimeInterval:(NSTimeInterval)interval repeat:(BOOL)repeat block:(LPMTimerBlock)block {
    return [self firedTimerWithInterval:interval repeat:repeat rightNow:YES block:block];
}


- (void)fire {
    if (self.status != LPMTimerPreparedToFire) {
//        if (self.status == LPMTimerInvalidated) {
//            NSLog(@"The timer you have fire has been invalidated!");
//        }
        return;
    }
    if (!self.repeat) {
        self.selfForNotRepeatTimer = self;
    }
    if ([NSThread isMainThread]) {
        _timerRunloop = CFRunLoopGetMain();
    }else{
        _timerRunloop = [[self class] timerRunloop];
    }
    CFAbsoluteTime time = CFDateGetAbsoluteTime((CFDateRef)[NSDate dateWithTimeIntervalSinceNow:self.scheduleRightNow ?0:self.timeInterval]);
    CFRunLoopTimerSetNextFireDate(_timerRef, time);
    CFRunLoopAddTimer(_timerRunloop, _timerRef, kCFRunLoopDefaultMode);
    self.status = LPMTimerFiring;
//    NSLog(@"fired");
}

- (void)pause {
    if (self.status != LPMTimerFiring) {
//        if (self.status == LPMTimerInvalidated) {
//            NSLog(@"The timer you have paused has been invalidated!");
//        }
        return;
    }
    CFRunLoopTimerSetNextFireDate(_timerRef, CFDateGetAbsoluteTime((CFDateRef)[NSDate dateWithTimeIntervalSinceNow:kCFAbsoluteTimeIntervalSince1904]));
    NSTimeInterval timeHasPass = [[NSDate date] timeIntervalSinceDate:self.lastScheduleDate];
    self.timeForResume = self.timeInterval - timeHasPass;
    self.status = LPMTimerPaused;
//    NSLog(@"paused");
}
- (void)resume {
    if (self.status != LPMTimerPaused) {
//        if (self.status == LPMTimerInvalidated) {
//            NSLog(@"The timer you have resumed has been invalidated!");
//        }
        return;
    }
    CFAbsoluteTime time = CFDateGetAbsoluteTime((CFDateRef)[NSDate dateWithTimeIntervalSinceNow:self.timeForResume]);
    CFRunLoopTimerSetNextFireDate(_timerRef, time);
    self.status = LPMTimerFiring;
//    NSLog(@"resumed");
}

- (void)invalidate {
    if (self.status == LPMTimerInvalidated) {
//        NSLog(@"The timer you have invalidated has been invalidated already!");
        return;
    }
    CFRunLoopTimerInvalidate(_timerRef);
    self.status = LPMTimerInvalidated;
    self.selfForNotRepeatTimer = nil;
//    NSLog(@"invalidated");
}

- (BOOL )isValid {
    return (self.status != LPMTimerInvalidated) ? YES : NO;
}

+ (CFRunLoopRef )timerRunloop {
    static NSThread *timerThread = nil;
    static CFRunLoopRef timerRunloop = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        timerThread = [[NSThread alloc]initWithBlock:^{
            @autoreleasepool {
                timerRunloop = CFRunLoopGetCurrent();
                CFRunLoopTimerRef timer = CFRunLoopTimerCreateWithHandler(CFAllocatorGetDefault(), CFAbsoluteTimeGetCurrent(), kCFAbsoluteTimeIntervalSince1904, 0, 0, ^(CFRunLoopTimerRef timer) {
                    
                });
                CFRunLoopAddTimer(timerRunloop, timer, kCFRunLoopDefaultMode);
                
                CFRelease(timer);
                
                dispatch_semaphore_signal(sem);
                CFRunLoopRun();
            }
            
        }];
        timerThread.name = @"LPMTimer Thread";
        [timerThread start];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    });
    return timerRunloop;
}
@end
