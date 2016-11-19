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


protocol ServerInterface {
    func getProducts() -> Observable<[Product]>
    func placeOrder(items: [OrderItem]) -> Observable<Order>
    func payOrder(order: Order, transactionID: String) -> Observable<Order>
}

class ServerManager: ServerInterface {

    static let sharedInstance = ServerManager()

    let disposeBag = DisposeBag()

    func getProducts() -> Observable<[Product]> {
        return requestJSON(router: APIRouter.getProducts).map { (urlResponse, jsonData) -> [Product] in
            guard let json = jsonData as? [String: Any],
            let prodcuts = json["products"] as? [[String: Any]]
                else { throw RequestError.parsingError }
            return prodcuts.map(Product.init)
        }
    }

    func placeOrder(items: [OrderItem]) -> Observable<Order> {
        return requestJSON(router: APIRouter.placeOrder(order: items, userName: User.shared.name.value ?? "", fcmToken: "")).map { (urlResponse, jsonData) -> Order in
            guard let json = jsonData as? [String: Any] else {
                throw RequestError.parsingError
            }
            return Order.init(json: json)
        }
    }

    func payOrder(order: Order, transactionID: String) -> Observable<Order> {
        return requestJSON(router: .payOrder(orderID: order.id, paymentID: transactionID)).map { (urlResponse, jsonData) -> Order in
            guard let json = jsonData as? [String: Any] else {
                throw RequestError.parsingError
            }
            return Order.init(json: json)
        }
    }
}

enum RequestError: Error {
    case parsingError
}

fileprivate func requestJSON(router: APIRouter) -> Observable<(HTTPURLResponse, Any)> {
    return RxAlamofire.requestJSON(router.method, router, parameters: router.result.parameters, encoding: router.encoding, headers: router.headers)
}
