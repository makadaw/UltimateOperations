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
@property (nonatomic, getter=isOperationCancelled) BOOL operationCancelled;

@end

@implementation UOOperation
@synthesize operationCancelled=_operationCancelled;

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
    [super cancel];
    // TODO use one write lock instead two
    self.operationCancelled = YES;
}

- (void)setState:(UOOperationState)state {
    pthread_rwlock_wrlock(&self->_lock);
    
    //TODO check is valid transiction
    if (_state != state
        && state > _state
        && (!_operationCancelled || (_operationCancelled && state == UOOperationStateFinished))) {
        NSString *oldStateKey = PropertyNameFromUOOperationState(_state);
        NSString *newStateKey = PropertyNameFromUOOperationState(state);
        
        [self willChangeValueForKey:oldStateKey];
        [self willChangeValueForKey:newStateKey];
        _state = state;
        [self didChangeValueForKey:newStateKey];
        [self didChangeValueForKey:oldStateKey];
    }
    
    pthread_rwlock_unlock(&self->_lock);
}

- (void)setOperationCancelled:(BOOL)operationCancelled {
    pthread_rwlock_wrlock(&self->_lock);
    if (_operationCancelled != operationCancelled) {
        [self willChangeValueForKey:@"isCancelled"];
        _operationCancelled = operationCancelled;
        [self didChangeValueForKey:@"isCancelled"];
    }
    pthread_rwlock_unlock(&self->_lock);
}

- (BOOL)isOperationCancelled {
    BOOL operationCancelled;
    pthread_rwlock_rdlock(&self->_lock);
    operationCancelled = _operationCancelled;
    pthread_rwlock_unlock(&self->_lock);
    return operationCancelled;
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
BOOL_LOCK_READING(isCancelled, _operationCancelled)

@end
