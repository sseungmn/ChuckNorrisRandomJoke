//
//  JokeAPIProviderTests.swift
//  ChuckNorrisRandomJokeTests
//
//  Created by seungminOH on 2022/04/15.
//

import XCTest
@testable import ChuckNorrisRandomJoke

class JokeAPIProviderTests: XCTestCase {
    var sut: JokeAPIProvider!

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_fetchRandomJoke() {
        sut = JokeAPIProvider(isStub: true)

        let expectation = XCTestExpectation()

        let expectedJoke = try? JSONDecoder().decode(
            JokeResponse.self,
            from: JokeAPI
                .randomJoke("Oh", "Seungmin", ["nerdy"])
                .sampleData
        ).value

        sut.fetchRandomJoke(firstName: "Oh", lastName: "Seungmin", categories: ["nerdy"]) { result in
            switch result {
            case .success(let joke):
                XCTAssertEqual(expectedJoke?.joke, joke.joke)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func test_fetchRandomJoke_failure() {
        sut = JokeAPIProvider(isStub: true, sampleStatusCode: 401)

        let expectation = XCTestExpectation()

        sut.fetchRandomJoke(firstName: "Oh", lastName: "Seungmin", categories: ["nerdy"]) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "UnknownError")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
