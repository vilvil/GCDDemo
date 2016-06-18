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
    
    [self gcdApply];
    
}




#pragma - apply

- (void)gcdApply
{
    // 1.dispatch_apply 相当于dispatch_sync 和 dispatch_group 的结合
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
//    dispatch_apply(10, queue, ^(size_t index) {
//       
//       NSLog(@"%zu",index);
//    });
//    
//    NSLog(@"done");
    
    
    // 2.利用dispatch_apply处理数组
//    NSArray *array = @[@"he",@"jo",@"le",@"ke",@"mo"];
//    dispatch_apply(array.count, queue, ^(size_t index) {
//        
//        NSLog(@"%zu: %@,%@",index,array[index],[NSThread currentThread]);
//    });
    
    
    // 3.
    NSArray *array = @[@"he",@"jo",@"le",@"ke",@"mo"];
    dispatch_async(queue, ^{
        NSLog(@"线程:%@",[NSThread currentThread]);
        // 因为dispatch_apply会阻塞当前调用的线程，所以放到其他线程去执行耗时间操作 ,并行处理数组
        dispatch_apply(array.count, queue, ^(size_t index) {
            
            NSLog(@"%zu: %@,%@",index,array[index],[NSThread currentThread]);
            
        });
        
        // 执行完上面处理后再回到主线程处理UI
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"处理UI");
        });
        
    });
}

#pragma - gcd sync
- (void)gcdSync
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSLog(@"1:%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"2:%@",[NSThread currentThread]);
    });
    
    
    dispatch_sync(queue, ^{
        NSLog(@"%@",[NSThread currentThread]);
        sleep(3);
    });
    dispatch_async(queue, ^{
        NSLog(@"3:%@",[NSThread currentThread]);
    });
    
    NSLog(@"代码执行here");
}

- (void)gcdSyncLock
{
    // 死锁例子
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//    
//    dispatch_sync(mainQueue, ^{
//         NSLog(@"执行:%@",[NSThread currentThread]);
//    });

    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        NSLog(@"执行:%@",[NSThread currentThread]);
        dispatch_sync(mainQueue, ^{
            NSLog(@"执行:%@",[NSThread currentThread]);
        });
    });

//    dispatch_queue_t queue = dispatch_queue_create("com.gcd.lock", NULL);
//    dispatch_async(queue, ^{
//        dispatch_sync(queue, ^{
//            NSLog(@"执行:%@",[NSThread currentThread]);
//        });
//    });

    // 综合上面例子，死锁的原因是，在串行的队列里调用同步方法，同步方法指定在该串行队列
}

#pragma - gcd barrier_async
- (void)gcdBarrierAsync
{
    // 数据库访问的时候可以同时并行读取处理，但是当要加入写入处理的时候就不能并行执行了，这会造成数据错误，多线程的数据竞争问题
    dispatch_queue_t queue = dispatch_queue_create("com.example.gcd.barrier", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"读取操作1-%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"读取操作2-%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"读取操作3-%@",[NSThread currentThread]);
    });
    
    // 此时如果执行这种写入 那么可能出现异常，或者读取的数据不符合期待的
//    dispatch_async(queue, ^{
//        NSLog(@"写入操作");
//    });

    // 用这种方法实现写入，那么就会等上面的并行读取操作完成后再执行写入，等写入完成后再并行执行下面的读取
    dispatch_barrier_async(queue, ^{
        sleep(10);
        NSLog(@"写入操作-%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"读取操作4-%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"读取操作5-%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"读取操作6-%@",[NSThread currentThread]);
    });
    
    
}


#pragma - gcd group 
- (void)gcdGroup
{
    dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"任务一%@",[NSThread currentThread]);
        
    });
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"任务二%@",[NSThread currentThread]);
        
    });
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"任务三%@",[NSThread currentThread]);
        
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"所有任务完成");
    });
    
//    dispatch_release(group);mrc
}

- (void)gcdGroupWait
{
    dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"任务一%@",[NSThread currentThread]);
        
    });
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"任务二%@",[NSThread currentThread]);
        
    });
    dispatch_group_async(group, globalQueue, ^{
        sleep(10);
        NSLog(@"任务三%@",[NSThread currentThread]);
        
    });


    NSLog(@"代码执行here");
    // 等待超时时间的，DISPATCH_TIME_FOREVER永远等待组里的代码运行完成，如果组里的代码没完成，下面的代码是不走的
    long result =  dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"代码执行here");

    if (result==0) {
        NSLog(@"执行完成");
    }else{
        NSLog(@"执行中");
    }
    
    NSLog(@"代码执行here");
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
