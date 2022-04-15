//
//  MockJokeAPI.swift
//  ChuckNorrisRandomJoke
//
//  Created by seungminOH on 2022/04/15.
//

import Foundation

extension JokeAPI {
    var sampleData: Data {
        Data(
            """
            {
                "type": "success",
                    "value": {
                    "id": 459,
                    "joke": "Chuck Norris can solve the Towers of Hanoi in one move.",
                    "categories": []
                }
            }
            """.utf8
        )
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    var resumeDidCall: () -> Void = {}

    override func resume() {
        resumeDidCall()
    }
}

class MockURLSession: URLSessionProtocol {

    var makeRequestFail = false
    init(makeRequestFail: Bool = false) {
        self.makeRequestFail = makeRequestFail
    }

    var sessionDataTask: MockURLSessionDataTask?

    // dataTask를 구현합니다.
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        // 성공 시 callback으로 넘겨줄 response
        let successResponse = HTTPURLResponse(
            url: JokeAPI.randomJoke.url,
            statusCode: 200,
            httpVersion: "2",
            headerFields: nil
        )

        // 실패 시 callback으로 넘겨줄 response
        let failureResponse = HTTPURLResponse(
            url: JokeAPI.randomJoke.url,
            statusCode: 410,
            httpVersion: "2",
            headerFields: nil
        )

        let sessionDataTask = MockURLSessionDataTask()

        // resume()이 호출되면 completionHandler()가 호출되도록 한다.
        sessionDataTask.resumeDidCall = {
            if self.makeRequestFail {
                completionHandler(nil, failureResponse, nil)
            } else {
                completionHandler(JokeAPI.randomJoke.sampleData, successResponse, nil)
            }
        }
        self.sessionDataTask = sessionDataTask
        return sessionDataTask
    }
}
