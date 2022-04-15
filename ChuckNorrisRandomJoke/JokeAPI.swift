//
//  JokeAPI.swift
//  ChuckNorrisRandomJoke
//
//  Created by seungminOH on 2022/04/15.
//

import Foundation

enum JokeAPI {
    case randomJoke

    static let baseURL = "https://api.icndb.com/"

    var path: String {
        switch self {
        case .randomJoke:
            return "jokes/random"
        }
    }
    var url: URL {
        return URL(string: JokeAPI.baseURL + path)!
    }
}

enum APIError: LocalizedError {
    case unknownError

    var errorDescription: String? {
        switch self {
        case .unknownError:
            return "UnknownError"
        }
    }
}

protocol URLSessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

class JokeAPIProvider {
    let session: URLSessionProtocol
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func fetchRandomJoke(completion: @escaping (Result<Joke, Error>) -> Void) {
        let request = URLRequest(url: JokeAPI.randomJoke.url)

        let task: URLSessionDataTask = session
            .dataTask(with: request) { data, urlResponse, error in
                guard let response = urlResponse as? HTTPURLResponse,
                      (200...399).contains(response.statusCode) else {
                    completion(.failure(error ?? APIError.unknownError))
                    return
                }

                if let data = data,
                   let jokeResponse = try? JSONDecoder().decode(JokeResponse.self, from: data) {
                    completion(.success(jokeResponse.value))
                    return
                }
                completion(.failure(APIError.unknownError))
            }

        task.resume()
    }
}
