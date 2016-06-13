//
//  ViewController.m
//  GCDDemo
//
//  Created by vivi on 16/6/13.
//  Copyright © 2016年 vivi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self gcdAfter];
    
    
    
    
    
}

#pragma - gcd group 
- (void)gcdGroup
{
    
}


#pragma - gcd 追加延迟任务
- (void)gcdAfter
{
    // 这个方法是添加延时任务，不是过多少时间执行任务，不能用于严格时间要求的时候
    // 计算相对时间
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3ull*NSEC_PER_SEC);
    NSLog(@"执行");
    dispatch_after(time, dispatch_get_main_queue(), ^{
        
        NSLog(@"3秒");
        
    });
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
    });
    
    // 在绝对时间的任务
    NSDate *date = [NSDate date];
    NSLog(@"%@",date.description);
    dispatch_after(getDispatchTimeByDate(date), dispatch_get_main_queue(), ^{
        
        NSLog(@"绝对时间的任务");
        
    });
}

// 获取绝对时间
static inline dispatch_time_t getDispatchTimeByDate(NSDate *date)
{
    NSTimeInterval interval;
    double second,subsecond;
    struct timespec time;
    dispatch_time_t milestone;
    
    interval = [date timeIntervalSince1970];
    subsecond = modf(interval, &second);
    time.tv_sec = second;
    time.tv_nsec = subsecond * NSEC_PER_SEC;
    milestone = dispatch_walltime(&time, 0);
    
    return milestone;
}


#pragma - gcd 变更优先级
- (void)gcdSetTarget
{
    // dispatch_queue_create 默认创建的串行和并行队列的优先级和默认优先级的全局队列一样
    // 利用dispatch_set_target_queue可以修改创建的队列的优先级
    dispatch_queue_t defQueue = dispatch_queue_create("com.gcd.default.demo", NULL);
    
    dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    dispatch_set_target_queue(defQueue, globalQueue);
    
    dispatch_async(defQueue, ^{
        NSLog(@"队列:%@",[NSThread currentThread]);
    });

    
    // 多个串行队列指定到一个串行队列中，本来可以并行执行的任务，在目标串行队列中只能同时执行一个处理
    dispatch_queue_t defQueue2 = dispatch_queue_create("com.gcd.default2.demo", NULL);
    
    dispatch_queue_t defQueue3 = dispatch_queue_create("com.gcd.default3.demo", NULL);
    
    dispatch_queue_t defQueue4 = dispatch_queue_create("com.gcd.default4.demo", NULL);
    
    
    dispatch_set_target_queue(defQueue3, defQueue2);
    dispatch_set_target_queue(defQueue4, defQueue2);
    
    // 下面的任务都在一个线程执行
    dispatch_async(defQueue2, ^{
        NSLog(@"队列2:%@",[NSThread currentThread]);
    });
    
    dispatch_async(defQueue2, ^{
        NSLog(@"队列2 任务2:%@",[NSThread currentThread]);
    });
    
    dispatch_async(defQueue3, ^{
        NSLog(@"队列3:%@",[NSThread currentThread]);
    });
    
    dispatch_async(defQueue3, ^{
        NSLog(@"队列3 任务2 :%@",[NSThread currentThread]);
    });
    
    
    dispatch_async(defQueue4, ^{
        NSLog(@"队列4:%@",[NSThread currentThread]);
    });
    
    dispatch_async(defQueue4, ^{
        NSLog(@"队列4 任务2:%@",[NSThread currentThread]);
    });
    
    
}

- (void)gcdSetTatgetMain
{
    dispatch_queue_t defQueue = dispatch_queue_create("com.gcd.default.demo", NULL);
    
    dispatch_queue_t mainQueue =  dispatch_get_main_queue();
    
    dispatch_set_target_queue(defQueue, mainQueue);
    
    dispatch_async(defQueue, ^{
        NSLog(@"队列:%@",[NSThread currentThread]);
    });
}

#pragma - gcd队列的获取
- (void)gcdMainAndGlobal
{
    // 获取主队列 该队列为serial dispatch queue 串行队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
//    * The global concurrent queues may still be identified by their priority,
//    * which map to the following QOS classes:
//    *  - DISPATCH_QUEUE_PRIORITY_HIGH:         QOS_CLASS_USER_INITIATED
//    *  - DISPATCH_QUEUE_PRIORITY_DEFAULT:      QOS_CLASS_DEFAULT
//    *  - DISPATCH_QUEUE_PRIORITY_LOW:          QOS_CLASS_UTILITY
//    *  - DISPATCH_QUEUE_PRIORITY_BACKGROUND:   QOS_CLASS_BACKGROUND
//    *
//    * @param flags
//    * Reserved for future use. Passing any value other than zero may result in
//        * a NULL return value.

//#define DISPATCH_QUEUE_PRIORITY_HIGH 2
//#define DISPATCH_QUEUE_PRIORITY_DEFAULT 0
//#define DISPATCH_QUEUE_PRIORITY_LOW (-2)
//#define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
    
    // 高优先级
    dispatch_queue_t globalDispatchQueueHigh = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    // 默认优先级
    dispatch_queue_t globalDispatchQueueDef = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 低优先级
     dispatch_queue_t globalDispatchQueueLow = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    
    // 后台优先级
     dispatch_queue_t globalDispatchQueueBg = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
}

#pragma - gcd 队列的创建
- (void)gcdSerialQueueCreate{
    
    // 创建多个串行队列 可以达到并行队列的效果 任务在多个线程执行 但是同个队列的任务在同个线程执行
    dispatch_queue_t serialQueue1 = dispatch_queue_create("com.demo.gcd.serialdispatchqueue1", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t serialQueue2 = dispatch_queue_create("com.demo.gcd.serialdispatchqueue2", NULL);
    
    dispatch_queue_t serialQueue3 = dispatch_queue_create("com.demo.gcd.serialdispatchqueue3", NULL);
    
    dispatch_queue_t serialQueue4 = dispatch_queue_create("com.demo.gcd.serialdispatchqueue4", NULL);
    
    
    dispatch_async(serialQueue1, ^{
        NSLog(@"队列1:%@",[NSThread currentThread]);
    });
    
    dispatch_async(serialQueue1, ^{
        NSLog(@"队列1:%@",[NSThread currentThread]);
    });
    
    dispatch_async(serialQueue2, ^{
        NSLog(@"队列2:%@",[NSThread currentThread]);
    });
    
    dispatch_async(serialQueue3, ^{
        NSLog(@"队列3:%@",[NSThread currentThread]);
    });
    
    dispatch_async(serialQueue4, ^{
        NSLog(@"队列4:%@",[NSThread currentThread]);
    });
    
    // mrc下要释放队列对象
    // dispatch_release(serialQueue1);
    
    
    
}

#pragma - gcd 代码聚合
- (void)gcd
{
    // GCD常用方法
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 耗时间操作
        NSLog(@"耗时间操作%@",[NSThread currentThread]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // 主线程处理UI
            NSLog(@"主线程处理UI%@",[NSThread currentThread]);
            
        });
        
    });

}


#pragma - 利用prefornSel 实现gcd方法的通用功能 。 代码分散
- (void)doTaskInBackGround
{
    [self performSelectorInBackground:@selector(doWork) withObject:nil];
}

- (void)doWork
{
    @autoreleasepool {
        // 后台耗时间操作
        NSLog(@"耗时间操作%@",[NSThread currentThread]);
        
        [self performSelectorOnMainThread:@selector(doneWork) withObject:nil waitUntilDone:NO];
    }

}

- (void)doneWork
{
    // 主线程更新UI
     NSLog(@"主线程处理UI%@",[NSThread currentThread]);
}

@end
