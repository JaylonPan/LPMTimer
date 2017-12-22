//
//  LPMTimer.h
//  TestHookUtils
//
//  Created by Jaylon on 2017/12/21.
//  Copyright © 2017年 Jaylon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LPMTimer;
typedef void (^LPMTimerBlock)(LPMTimer *timer);
typedef NS_ENUM(NSUInteger, LPMTimerStatus) {
    LPMTimerPreparedToFire,//The timer's instance was created  but not fired.
    LPMTimerFiring,//The timer is firing .
    LPMTimerPaused,//Timer was paused.
    LPMTimerInvalidated//Timer was invalid,and coundn't be fire again.
};

@interface LPMTimer : NSObject

@property (readonly, getter=isRepeat) BOOL repeat;

@property (readonly) NSTimeInterval timeInterval;

// Get status of the timer currently.
@property (readonly) LPMTimerStatus status;
// Setting a tolerance for a timer allows it to fire later than the scheduled fire date, improving the ability of the system to optimize for increased power savings and responsiveness. The timer may fire at any time between its scheduled fire date and the scheduled fire date plus the tolerance. The timer will not fire before the scheduled fire date. For repeating timers, the next fire date is calculated from the original fire date regardless of tolerance applied at individual fire times, to avoid drift. The default value is zero, which means no additional tolerance is applied. The system reserves the right to apply a small amount of tolerance to certain timers regardless of the value of this property.
// As the user of the timer, you will have the best idea of what an appropriate tolerance for a timer may be. A general rule of thumb, though, is to set the tolerance to at least 10% of the interval, for a repeating timer. Even a small amount of tolerance will have a significant positive impact on the power usage of your application. The system may put a maximum value of the tolerance.
@property NSTimeInterval tolerance;

@property (readonly, getter=isValid) BOOL valid;

//Notice: If the timer didn't be hold by a strong refrence, and the repeat is NO,it will be dealloced.

/**********************                         START                        **********************/
//These methods create the LPMTimer's instance but not add to any runloop, the timer will be added
//when the method 'fire' be called.

- (instancetype)initWithInterval:(NSTimeInterval )interval
                              repeat:(BOOL)repeat
                               block:(LPMTimerBlock )block;
+ (instancetype)timerWithInterval:(NSTimeInterval )interval
                               repeat:(BOOL )repeat
                                block:(LPMTimerBlock )block;
//This method will call the block right now.
+ (instancetype)timerScheduleRightNowWithTimeInterval:(NSTimeInterval)interval
                                               repeat:(BOOL)repeat
                                                block:(LPMTimerBlock)block;

/**********************                         END                          **********************/


/**********************                         START                        **********************/
//If these methods following have been invoked in main thread, we will add timer to the main runloop,
//otherwise we will add the timer to a default runloop which we created for timers named 'LPMTimerThread'.
//And automoticly fire the timer.

+ (instancetype)firedTimerWithInterval:(NSTimeInterval )interval
                                    repeat:(BOOL )repeat
                                     block:(LPMTimerBlock )block;
//This method will call the block right now.
+ (instancetype)firedTimerScheduleRightNowWithTimeInterval:(NSTimeInterval )interval
                                                    repeat:(BOOL )repeat
                                                     block:(LPMTimerBlock )block;
/**********************                         END                          **********************/


//The method 'fire' will add timer to a runloop. and if this method has been called in main thread,
//we will add timer in main runloop,otherwise we will add timer in a default runloop which we
//created for timer named 'LPMTimerThread'.
- (void)fire;
//Pause the timer.
- (void)pause;
//Resume the timer.
- (void)resume;
//Invalidate the timer,and the timer couldn't be fired any more.
- (void)invalidate;

@end
