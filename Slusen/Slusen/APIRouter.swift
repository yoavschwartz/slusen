//
//  APIRouter.swift
//  Slusen
//
//  Created by Yoav Schwartz on 29/10/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible, URLConvertible, CustomStringConvertible {
    static let baseURLString: String = "http://www.tritian.com/p3/api"

    case getProducts

    var result: (path: String, parameters: [String: AnyObject]) {
        switch self {
        case .getProducts:
            return ("/products", [:])
        }
    }

    var method: Alamofire.HTTPMethod {
        switch self {
        case .getProducts:
            return .get
        }
    }

    // swiftlint:disable variable_name
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: APIRouter.baseURLString)!
        var urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
        urlRequest.httpMethod = method.rawValue
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        return try URLEncoding().encode(urlRequest, with: result.parameters)
    }

    var headers: [String: String] {
        return ["Accept": "application/json"]
    }

    func asURL() throws -> URL {
        return URL(string: APIRouter.baseURLString)!.appendingPathComponent(result.path)
    }
    // swiftlint:enable variable_name
    var description: String {
        return "HTTPMethod: \(method), URL: \(try! asURL())"
    }

}
