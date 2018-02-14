//
//  UOBlockOperation.m
//  UltimateOperationsTests
//
//  Created by mainuser on 2/14/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import "UOBlockOperation.h"

@interface UOBlockOperation()
@property (copy) void (^block)(void);

@end

@implementation UOBlockOperation

- (instancetype)initWithBlock:(void (^)(void))block {
    if ((self = [super init])) {
        _block = block;
    }
    return self;
}

- (void)main {
    self.block();
    [self finish];
}

@end
