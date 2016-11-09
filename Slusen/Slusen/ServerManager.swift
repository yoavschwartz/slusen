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
        //TEST
        let price = items.map { item -> Int in
            item.amount * item.product.priceInCents
        }.reduce(0, +)
        let order = Order(id: 1, number: 26, priceInCents: price, items: items, fetchIdentifier: "xxxx", status: .pendingPayment)
        return Observable.just(order)
    }

    func payOrder(order: Order, transactionID: String) -> Observable<Order> {
        //TEST
        var order = order
        order.status = .pendingPreperation
        return Observable.just(order)
    }
}

enum RequestError: Error {
    case parsingError
}

fileprivate func requestJSON(router: APIRouter) -> Observable<(HTTPURLResponse, Any)> {
    return RxAlamofire.requestJSON(router.method, router, parameters: router.result.parameters, headers: router.headers)
}
