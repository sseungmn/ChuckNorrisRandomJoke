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

    override func setUpWithError() throws {
        sut = .init(session: MockURLSession())
    }

    func test_fetchRandomJoke() {
        let expectation = XCTestExpectation()
        let response = try? JSONDecoder().decode(
            JokeResponse.self,
            from: JokeAPI.randomJoke.sampleData
        )

        sut.fetchRandomJoke { result in
            switch result {
            case .success(let joke):
                XCTAssertEqual(joke.id, response?.value.id)
                XCTAssertEqual(joke.joke, response?.value.joke)
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func test_fetchRandomJoke_failure() {
        sut = .init(session: MockURLSession(makeRequestFail: true))
        let expectation = XCTestExpectation()

        sut.fetchRandomJoke { result in
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
