# LPMTimer
A Timer which is easier to use than NSTimer.
## Using the timer in main thread.
```
static NSInteger i;
    __weak typeof(self) weakSelf = self;
    LPMTimerBlock block = ^(LPMTimer *timer){
        typeof(self) strongSelf = weakSelf;
        strongSelf.label.text = [NSString stringWithFormat:@"hahahaha %zd",i];
        NSLog(@"%@",[NSThread currentThread]);
        NSLog(@"timer: %zd",i++);
    };
    self.timer = [LPMTimer timerWithInterval:3 repeat:YES block:block];
```
## Using the timer in sub thread.
The timer will be deallocated after schedule when repeat is NO.
When the repeat is YES,the timer will be invalidated and deallocated if you don't hold it by a strong refrence pointer.
```
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
        [LPMTimer firedTimerWithInterval:1 repeat:NO block:block];
    });
```


