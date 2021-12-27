//
//  ClinicalInc_MobileTechAssessmentUITestsLaunchTests.m
//  ClinicalInc_MobileTechAssessmentUITests
//
//  Created by user206074 on 12/27/21.
//

#import <XCTest/XCTest.h>

@interface ClinicalInc_MobileTechAssessmentUITestsLaunchTests : XCTestCase

@end

@implementation ClinicalInc_MobileTechAssessmentUITestsLaunchTests

+ (BOOL)runsForEachTargetApplicationUIConfiguration {
    return YES;
}

- (void)setUp {
    self.continueAfterFailure = NO;
}

- (void)testLaunch {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    // Insert steps here to perform after app launch but before taking a screenshot,
    // such as logging into a test account or navigating somewhere in the app

    XCTAttachment *attachment = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
    attachment.name = @"Launch Screen";
    attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:attachment];
}

@end
