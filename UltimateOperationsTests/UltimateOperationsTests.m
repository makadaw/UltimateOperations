//
//  UltimateOperationsTests.m
//  UltimateOperationsTests
//
//  Created by mainuser on 2/14/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "UOOperation.h"
#import "UOBlockOperation.h"


@interface UltimateOperationsTests : XCTestCase
@property (nonatomic) NSOperationQueue *queue;

@end

@implementation UltimateOperationsTests

- (void)setUp {
    [super setUp];
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
}

- (void)tearDown {
    [self.queue cancelAllOperations];
    [super tearDown];
}

- (void)testSecondOperationCancellation {
    __block int count = 0;
    XCTestExpectation *exp = [self expectationWithDescription:@"First operation"];
    UOBlockOperation *op1 = [[UOBlockOperation alloc] initWithBlock:^{
        sleep(2);
        count++;
        [exp fulfill];
    }];
    [self.queue addOperation:op1];
    UOBlockOperation *op2 = [[UOBlockOperation alloc] initWithBlock:^{
        sleep(5);
        count++;
        XCTAssert(NO, @"Second operation also executed");
    }];
    [self.queue addOperation:op2];
    sleep(1);
    [self.queue cancelAllOperations];
    [self waitForExpectations:@[exp] timeout:10];
    
    XCTAssertEqual(count, 1);
}

@end
