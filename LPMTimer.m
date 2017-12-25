//
//  LPMTimer.m
//  TestHookUtils
//
//  Created by Jaylon on 2017/12/21.
//  Copyright © 2017年 Jaylon. All rights reserved.
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
@property (nonatomic, copy) NSArray *IntervalList;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, assign) NSUInteger currentIntervalIndex;
@property (nonatomic, assign) BOOL scheduleRightNow;
@property (nonatomic, strong) NSDate *lastScheduleDate;
@property (nonatomic, assign) NSTimeInterval timeForResume;
@property (assign ) LPMTimerStatus status;
@property (nonatomic, assign) BOOL isFirstSchedule;
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
    NSLog(@"LPMTimer deallocated!");
}
- (instancetype)initWithInterval:(NSTimeInterval)interval
                          repeat:(BOOL)repeat
                    intervalList:(NSArray *)intervalList
                         keyPath:(NSString *)keyPath
                        rightNow:(BOOL)rightNow
                           block:(LPMTimerBlock)block {
    if (self = [self init]) {
        self.timeInterval = interval;
        self.IntervalList = intervalList;
        self.keyPath = keyPath;
        self.scheduleRightNow = rightNow;
        self.repeat = repeat;
        self.block = block;
        self.isFirstSchedule = YES;
        [self getTimeInteval];
        CFAbsoluteTime time = CFDateGetAbsoluteTime((CFDateRef)[NSDate dateWithTimeIntervalSinceNow:rightNow ?0:self.timeInterval]);
        _timerRef = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, time, self.timeInterval, 0, 0, ^(CFRunLoopTimerRef timer) {
            self.lastScheduleDate = [NSDate date];
            self.block(self);
            if (!repeat) {
                [self invalidate];
            }
            if (self.IntervalList.count ) {
                if (!self.scheduleRightNow || !self.isFirstSchedule) {
                    self.currentIntervalIndex ++;
                }
                if (self.IntervalList.count > self.currentIntervalIndex) {
                    [self getTimeInteval];
                    CFAbsoluteTime theTime = CFDateGetAbsoluteTime((CFDateRef)[NSDate dateWithTimeIntervalSinceNow:self.timeInterval]);
                    CFRunLoopTimerSetNextFireDate(timer, theTime);
                }else{
                    [self invalidate];
                }
            }
            if (self.isFirstSchedule) {
                self.isFirstSchedule = NO;
            }
        });
        self.status = LPMTimerPreparedToFire;
    }
    return self;
}

- (instancetype)initWithInterval:(NSTimeInterval)interval repeat:(BOOL)repeat rightNow:(BOOL)rightNow block:(LPMTimerBlock)block {
    return [self initWithInterval:interval
                           repeat:repeat
                     intervalList:nil
                          keyPath:nil
                         rightNow:rightNow
                            block:block];
}

- (instancetype)initWithInterval:(NSTimeInterval)interval repeat:(BOOL)repeat block:(LPMTimerBlock)block {
    return [self initWithInterval:interval repeat:repeat rightNow:NO block:block];
}

- (instancetype)initWithIntervalList:(NSArray *)intervalList
                             kayPath:(NSString *)keyPath
                            rightNow:(BOOL )rightNow
                               block:(LPMTimerBlock )block {
    return [self initWithInterval:0
                           repeat:YES
                     intervalList:intervalList
                          keyPath:keyPath
                         rightNow:rightNow
                            block:block];
}

- (instancetype)initWithIntervalList:(NSArray *)intervalList
                             keyPath:(NSString *)keyPath
                               block:(LPMTimerBlock )block {
    return [self initWithIntervalList:intervalList kayPath:keyPath rightNow:NO block:block];
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

+ (instancetype)timerWithIntervalList:(NSArray *)intervalList keyPath:(NSString *)keyPath rightNow:(BOOL)rightNow block:(LPMTimerBlock )block {
    LPMTimer *timer = [[LPMTimer alloc]initWithIntervalList:intervalList kayPath:keyPath rightNow:rightNow block:block];
    return timer;
}
+ (instancetype)timerWithIntervalList:(NSArray *)intervalList keyPath:(NSString *)keyPath block:(LPMTimerBlock )block {
    return [self timerWithIntervalList:intervalList keyPath:keyPath rightNow:NO block:block];
}
+ (instancetype)timerScheduleRightNowWithTimeIntervalList:(NSArray *)intervalList keyPath:(NSString *)keyPath block:(LPMTimerBlock )block {
    return [self timerWithIntervalList:intervalList keyPath:keyPath rightNow:YES block:block];
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

+ (instancetype)firedTimerWithIntervalList:(NSArray *)intervalList keyPath:(NSString *)keyPath rightNow:(BOOL)rightNow block:(LPMTimerBlock )block {
    LPMTimer *timer = [self timerWithIntervalList:intervalList keyPath:keyPath rightNow:rightNow block:block];
    [timer fire];
    return timer;
}

+ (instancetype)firedTimerWithIntervalList:(NSArray *)intervalList keyPath:(NSString *)keyPath block:(LPMTimerBlock )block {
    return [self firedTimerWithIntervalList:intervalList keyPath:keyPath rightNow:NO block:block];
}

+ (instancetype)firedTimerScheduleRightNowWithIntervalList:(NSArray *)intervalList keyPath:(NSString *)keyPath block:(LPMTimerBlock )block {
    return [self firedTimerWithIntervalList:intervalList keyPath:keyPath rightNow:YES block:block];
}

- (void)fire {
    if (self.status != LPMTimerPreparedToFire) {
//        if (self.status == LPMTimerInvalidated) {
//            NSLog(@"The timer you have fire has been invalidated!");
//        }
        return;
    }
    if (!self.repeat || self.IntervalList.count) {
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

- (void)setTolerance:(NSTimeInterval)tolerance {
    if (!_timerRef) {
        return;
    }
    CFRunLoopTimerSetTolerance(_timerRef, tolerance);
}

- (NSTimeInterval )tolerance {
    if (!_timerRef) {
        return 0;
    }
   return CFRunLoopTimerGetTolerance(_timerRef);
}

- (NSTimeInterval )getTimeInteval {
    if (self.IntervalList.count) {
        id item = self.IntervalList[self.currentIntervalIndex];
        if (self.keyPath.length) {
            self.timeInterval = [[item valueForKeyPath:self.keyPath] doubleValue];
        }else{
            self.timeInterval = [item doubleValue];
        }
    }
    return self.timeInterval;
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
