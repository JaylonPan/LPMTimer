//
//  TestItem.m
//  LPMTimerDemo
//
//  Created by 金龙潘 on 2017/12/22.
//  Copyright © 2017年 金龙潘. All rights reserved.
//

#import "TestItem.h"

@implementation TestItem
+ (instancetype)itemWithInterval:(NSTimeInterval)interval {
    TestItem *item = [TestItem new];
    item.interval = interval;
    return item;
}
@end
