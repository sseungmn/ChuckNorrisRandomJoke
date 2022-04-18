//
//  JokeAPI.swift
//  ChuckNorrisRandomJoke
//
//  Created by seungminOH on 2022/04/15.
//

import Foundation
import Moya

enum JokeAPI {
    case randomJoke(
        _ firstName: String? = nil,
        _ lastName: String? = nil,
        _ categories: [String] = []
    )
}

extension JokeAPI: TargetType {

    var baseURL: URL {
        return URL(string: "https://api.icndb.com/")!
    }

    var path: String {
        switch self {
        case .randomJoke:
            return "jokes/random"
        }
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        switch self {
        case .randomJoke(let firstName, let lastName, let categories):
            var params: [String: Any?] = [
                "firstName": firstName,
                "lastName": lastName
            ]

            if categories.isEmpty == false {
                params["limitTo"] = "(categories)"
            }

            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String : String]? {
        nil
    }

    var sampleData: Data {
        switch self {
        case .randomJoke(let firstName, let lastName, let categoris):
            let firstName = firstName ?? "Chuck"
            let lastName = lastName ?? "Norris"

            return Data(
                    """
                    {
                       "type": "success",
                           "value": {
                           "id": 107,
                           "joke": "\(firstName) \(lastName) can retrieve anything from /dev/null.",
                           "categories": \(categoris)
                       }
                    }
                    """.utf8
            )
        }
    }
}

class JokeAPIProvider: ProviderProtocol {

    typealias T = JokeAPI
    let provider: MoyaProvider<JokeAPI>

    required init(
        isStub: Bool = false,
        sampleStatusCode: Int = 200,
        customEndpointClosure: ((JokeAPI) -> Endpoint)? = nil
    ) {
        provider = Self.consProvider(isStub, sampleStatusCode, customEndpointClosure)
    }
    init(provider: MoyaProvider<JokeAPI> = .init()) {
        self.provider = provider
    }

    func fetchRandomJoke(
        firstName: String? = nil,
        lastName: String? = nil,
        categories: [String] = [],
        completion: @escaping (Result<Joke, Error>) -> Void
    ) {
        provider.request(
            .randomJoke(firstName, lastName, categories)
        ) { response in
            switch response {
            case .success(let moyaResponse):
                guard (200...399).contains(moyaResponse.statusCode) else {
                    completion(.failure(APIError.unknownError))
                    return
                }
                guard let joke = try? JSONDecoder().decode(JokeResponse.self, from: moyaResponse.data).value else {
                    completion(.failure(APIError.decodingError))
                    return
                }
                completion(.success(joke))
            case .failure(let moyaError):
                completion(.failure(moyaError))
            }
        }
    }
}
