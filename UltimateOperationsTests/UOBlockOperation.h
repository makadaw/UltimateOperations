//
//  UOBlockOperation.h
//  UltimateOperationsTests
//
//  Created by mainuser on 2/14/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import "UOOperation.h"

@interface UOBlockOperation : UOOperation

- (instancetype)initWithBlock:(void (^)(void))block;

@end
