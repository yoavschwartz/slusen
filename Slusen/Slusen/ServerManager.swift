//
//  ServerManager.swift
//  Slusen
//
//  Created by Yoav Schwartz on 29/10/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxAlamofire
import Firebase


protocol ServerInterface {
    func getProducts() -> Observable<[Product]>
    func getOrders(fetchIdentifiers: [String]) -> Observable<[Order]>
    func placeOrder(items: [OrderItem]) -> Observable<Order>
    func payOrder(order: Order, transactionID: String) -> Observable<Order>
}

class ServerManager: ServerInterface {

    static let sharedInstance = ServerManager()

    let disposeBag = DisposeBag()

    func getProducts() -> Observable<[Product]> {
        return requestJSON(router: APIRouter.getProducts).map { (response, jsonData) -> [Product] in
            guard let json = jsonData as? [String: Any],
            let prodcuts = json["products"] as? [[String: Any]]
                else { throw RequestError.parsingError }
            return prodcuts.map(Product.init)
        }
    }

    func placeOrder(items: [OrderItem]) -> Observable<Order> {
        return requestJSON(router: APIRouter.placeOrder(order: items, userName: User.shared.name ?? "", fcmToken: FIRInstanceID.instanceID().token()!)).map { (response, jsonData) -> Order in
            guard let json = jsonData as? [String: Any], let orderJSON = json["order"] as? [String: Any]  else {
                throw RequestError.parsingError
            }
            return Order.init(json: orderJSON)
        }
    }

    func payOrder(order: Order, transactionID: String) -> Observable<Order> {
        return requestJSON(router: .payOrder(orderID: order.id, paymentID: transactionID)).map { (response, jsonData) -> Order in
            guard let json = jsonData as? [String: Any], let orderJSON = json["order"] as? [String: Any] else {
                throw RequestError.parsingError
            }
            return Order.init(json: orderJSON)
        }
    }

    func getOrders(fetchIdentifiers: [String]) -> Observable<[Order]> {
        return requestJSON(router: .getOrders(fetchIdentifiers: fetchIdentifiers)).map { (response, jsonData) -> [Order] in
            guard let json = jsonData as? [String: Any], let orders = json["orders"] as? [[String: Any]] else {
                throw RequestError.parsingError
            }
            return orders.map(Order.init(json:))
        }
    }

}

fileprivate func requestJSON(router: APIRouter) -> Observable<(HTTPURLResponse, Any)> {

    return RxAlamofire.request(router.method, router, parameters: router.result.parameters, encoding: router.encoding, headers: router.headers)
        .flatMap { request in
            return request
                .rx.responseData()
        }
        .flatMap { (response, data) -> Observable<(HTTPURLResponse, Any)> in
            if response.statusCode >= 200 && response.statusCode < 300 {
                return Observable.just((response,
                                        try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())))
            }

            let errorMessage = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())).flatMap({
                return ($0 as? [String: Any])?["error"] as? String
            }) ?? ""

            return Observable.error(RequestError.httpError(code: response.statusCode, errorMessage: errorMessage))
        }
        .observeOn(MainScheduler.instance)
}

enum RequestError: Error, CustomStringConvertible {
    case parsingError
    case httpError(code: Int, errorMessage: String)

    var description: String {
        switch self {
        case .parsingError: return "Server parsing error"
        case let .httpError(code, message): return "HTTP error: \(code)\n \(message)"

        }
    }
}

extension RequestError: LocalizedError {
    public var errorDescription: String? {
        return self.description
    }
}
