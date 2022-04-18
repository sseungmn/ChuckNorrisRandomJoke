//
//  MockJokeAPI.swift
//  ChuckNorrisRandomJoke
//
//  Created by seungminOH on 2022/04/15.
//

import Foundation
import Moya
import Alamofire
import SwiftUI

enum APIError: LocalizedError {
    case unknownError
    case decodingError

    var errorDescription: String? {
        switch self {
        case .unknownError:
            return "UnknownError"
        case .decodingError:
            return "DecodingError"
        }
    }
}

public protocol ProviderProtocol: AnyObject {
    associatedtype T: TargetType

    var provider: MoyaProvider<T> { get }
    init(
        isStub: Bool,
        sampleStatusCode: Int,
        customEndpointClosure: ((T) -> Endpoint)?
    )
}

public extension ProviderProtocol {
    static func consProvider(
        _ isStub: Bool = false,
        _ sampleStatusCode: Int = 200,
        _ customEndpointClosure: ((T) -> Endpoint)? = nil
    ) -> MoyaProvider<T> {
        if isStub == false {
            return MoyaProvider<T>(
                endpointClosure: { targetType in
                    return MoyaProvider<T>
                        .defaultEndpointMapping(for: targetType)
                },
                session: MoyaProvider<T>.defaultAlamofireSession()
            )
        } else {
            // 테스트 시에 호출되는 stub 클로져
            let endpointClousure = { (target: T) -> Endpoint in
                let sampleResponseClosure: () -> EndpointSampleResponse = {
                    EndpointSampleResponse.networkResponse(
                        sampleStatusCode,
                        target.sampleData
                    )
                }

                return Endpoint(
                    url: URL(target: target).absoluteString,
                    sampleResponseClosure: sampleResponseClosure,
                    method: target.method,
                    task: target.task,
                    httpHeaderFields: target.headers
                )
            }

            return MoyaProvider<T>(
                endpointClosure: customEndpointClosure ?? endpointClousure,
                stubClosure: MoyaProvider.immediatelyStub
            )
        }
    }
}
