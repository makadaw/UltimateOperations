//
//  UOOperation.m
//  UltimateOperations
//
//  Created by mainuser on 2/14/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import "UOOperation.h"
#import <pthread.h>

typedef NS_ENUM(NSInteger, UOOperationState) {
    UOOperationStateReady       = 1,
    UOOperationStateExecuting   = 2,
    UOOperationStateFinished    = 3,
};

static NSString *PropertyNameFromUOOperationState(UOOperationState state) {
    switch (state) {
        case UOOperationStateReady:        return @"isReady";
        case UOOperationStateExecuting:    return @"isExecuting";
        case UOOperationStateFinished:     return @"isFinished";
    }
    return @"";
}

@interface UOOperation () {
    pthread_rwlock_t _lock;
}
@property (nonatomic) UOOperationState state;

@end

@implementation UOOperation

- (instancetype)init {
    if ((self = [super init])) {
        pthread_rwlock_init(&self->_lock, NULL);
        self.state = UOOperationStateReady;
    }
    return self;
}

- (void)dealloc {
    pthread_rwlock_destroy(&self->_lock);
}

#pragma mark Operation work

- (void)main {
    [NSException raise:@"Must be implemented in subclass" format:@""];
}

#pragma mark Asynchronous operation

- (BOOL)isAsynchronous {
    return YES;
}

- (void)start {
    if (self.cancelled) {
        [self finish];
    } else {
        self.state = UOOperationStateExecuting;
        [self main];
    }
}

- (void)finish {
    self.state = UOOperationStateFinished;
}

- (void)cancel {
    pthread_rwlock_wrlock(&_lock);
    [super cancel];
    pthread_rwlock_unlock(&_lock);
}

- (void)setState:(UOOperationState)state {
    pthread_rwlock_wrlock(&_lock);
    
    //TODO check is valid transiction
    if (_state != state
        && state > _state
        && (!self.isCancelled || (self.isCancelled && state == UOOperationStateFinished))) {
        NSString *oldStateKey = PropertyNameFromUOOperationState(_state);
        NSString *newStateKey = PropertyNameFromUOOperationState(state);
        
        [self willChangeValueForKey:oldStateKey];
        [self willChangeValueForKey:newStateKey];
        _state = state;
        [self didChangeValueForKey:newStateKey];
        [self didChangeValueForKey:oldStateKey];
    }
    
    pthread_rwlock_unlock(&_lock);
}

#define BOOL_LOCK_READING(name, expression) \
- (BOOL)name { \
    BOOL name; \
    pthread_rwlock_rdlock(&_lock); \
    name = expression;\
    pthread_rwlock_unlock(&_lock);\
    return name;\
}

BOOL_LOCK_READING(isReady, self.state == UOOperationStateReady && [super isReady])
BOOL_LOCK_READING(isExecuting, self.state == UOOperationStateExecuting)
BOOL_LOCK_READING(isFinished, self.state == UOOperationStateFinished)
BOOL_LOCK_READING(isCancelled, [super isCancelled])

@end
