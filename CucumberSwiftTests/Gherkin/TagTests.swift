//
//  TagTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 7/16/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class TagTests: XCTestCase {
    let featureFileWithTags: String =
    """
    @featuretag
    Feature: Some terse yet descriptive text of what is desired

       @scenario1tag
       Scenario: Some determinable business situation
         Given a scenario with tags

       Scenario: Some other determinable business situation
         Given a scenario without tags

    """
    
    func testTagsAreScopedAndInheritedCorrectly() {
        let cucumber = Cucumber(withString: featureFileWithTags)
        XCTAssert(cucumber.features.first?.containsTag("featuretag") ?? false)
        XCTAssert(cucumber.features.first?.scenarios.first?.containsTag("featuretag") ?? false)
        XCTAssert(cucumber.features.first?.scenarios.first?.containsTag("scenario1tag") ?? false)
        XCTAssert(!(cucumber.features.first?.scenarios.last?.containsTag("scenario1tag") ?? true))
    }
    
    func testMultipleTagsSpaceSeparated() {
        let cucumber = Cucumber(withString: """
    Feature: Some terse yet descriptive text of what is desired
       @scenario1tag @someOtherTag
       Scenario: Some determinable business situation
         Given a scenario with tags
    """)
        XCTAssert(cucumber.features.first?.scenarios.first?.containsTag("scenario1tag") ?? false)
        XCTAssert(cucumber.features.first?.scenarios.first?.containsTag("someOtherTag") ?? false)
    }
    
    func testMultipleTagsNotSeparated() {
        let cucumber = Cucumber(withString: """
    Feature: Some terse yet descriptive text of what is desired
       @scenario1tag@someOtherTag
       Scenario: Some determinable business situation
         Given a scenario with tags
    """)
        XCTAssert(cucumber.features.first?.scenarios.first?.containsTag("scenario1tag") ?? false)
        XCTAssert(cucumber.features.first?.scenarios.first?.containsTag("someOtherTag") ?? false)
    }

    func testMultipleTagsCommaSeparated() {
        let cucumber = Cucumber(withString: """
    Feature: Some terse yet descriptive text of what is desired
       @scenario1tag, @someOtherTag
       Scenario: Some determinable business situation
         Given a scenario with tags
    """)
        XCTAssert(cucumber.features.first?.scenarios.first?.containsTag("scenario1tag") ?? false)
        XCTAssert(cucumber.features.first?.scenarios.first?.containsTag("someOtherTag") ?? false)
    }

    func testRunWithSpecificTags() {
        let cucumber = Cucumber(withString: featureFileWithTags)
        cucumber.environment["CUCUMBER_TAGS"] = "scenario1tag"
        
        var withTagsCalled = false
        cucumber.Given("a scenario with tags") { _, _ in
            withTagsCalled = true
        }
        var withoutTagsCalled = false
        cucumber.Given("a scenario without tags") { _, _ in
            withoutTagsCalled = true
        }
        
        cucumber.executeFeatures()
        
        XCTAssert(withTagsCalled)
        XCTAssertFalse(withoutTagsCalled)
    }
}