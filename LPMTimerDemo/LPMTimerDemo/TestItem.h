//
//  TestItem.h
//  LPMTimerDemo
//
//  Created by 金龙潘 on 2017/12/22.
//  Copyright © 2017年 金龙潘. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestItem : NSObject
@property (nonatomic ,assign) NSTimeInterval interval;
+(instancetype)itemWithInterval:(NSTimeInterval)interval;
@end
