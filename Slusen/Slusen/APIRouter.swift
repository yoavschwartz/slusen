//
//  APIRouter.swift
//  Slusen
//
//  Created by Yoav Schwartz on 29/10/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import Alamofire

enum APIRouter: URLConvertible, CustomStringConvertible {
    static let baseURLString: String = "http://www.tritian.com/p3/api"

    case getProducts
    case getOrders(fetchIdentifiers: [String])
    case placeOrder(order: [OrderItem], userName: String, fcmToken: String)
    case payOrder(orderID: Int, paymentID: String)

    var result: (path: String, parameters: [String: Any]) {
        switch self {
        case .getProducts: return ("/products", [:])
        case let .getOrders(fetchIdentifiers):
            return ("/orders", ["order": fetchIdentifiers])
        case let .placeOrder(items, userName, fcmToken):
            let order = items.map {
                ["product_id": $0.product.id, "quantity": $0.amount]
            }
            let parameters: [String: Any] = ["user_name": userName, "fcm_token": fcmToken ,"items": order]
            return ("/orders", parameters)
        case let .payOrder(orderID, paymentID):
            return ("/orders/\(orderID)", ["payment_id": paymentID])
        }
    }

    var method: Alamofire.HTTPMethod {
        switch self {
        case .getProducts, .getOrders:
            return .get
        case .placeOrder:
            return .post
        case .payOrder:
            return .put
        }
    }

    var headers: [String: String] {
        return ["Accept": "application/json", "Content-Type": "application/json"]
    }

    var encoding: ParameterEncoding {
        switch method {
        case .post: return JSONEncoding.default
        default: return URLEncoding()
        }
    }

    func asURL() throws -> URL {
        return URL(string: APIRouter.baseURLString)!.appendingPathComponent(result.path)
    }
    // swiftlint:enable variable_name
    var description: String {
        return "HTTPMethod: \(method), URL: \(try! asURL())"
    }

}
