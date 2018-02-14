//
//  UOOperationTests.m
//  UltimateOperationsTests
//
//  Created by mainuser on 2/14/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "UOOperation.h"

@interface TestOperation: UOOperation

@end

@interface UOOperationTests : XCTestCase
@end

@implementation UOOperationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testOperationInitialState {
    TestOperation *op = [[TestOperation alloc] init];
    XCTAssertTrue(op.isReady);
}

- (void)testOperationStartChangeStateToExecutable {
    TestOperation *op = [[TestOperation alloc] init];
    [op start];
    XCTAssertTrue(op.isExecuting);
}

- (void)testCancelledOperationDoNotExecuting {
    UOOperation *op = OCMPartialMock([UOOperation new]);
    OCMReject([op main]);
    [op cancel];
    [op start];
    XCTAssertTrue(op.isFinished);
}

@end

@implementation TestOperation

- (void)main {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self finish];
    });
}

@end
