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
        //print(Alamofire.request(APIRouter.placeOrder(order: items, userName: User.shared.name.value ?? "", fcmToken: ""), encoding: .JSON).debugDescription)
//        let order = items.map {
//            ["product_id": $0.product.id, "quantity": $0.amount]
//        }
//        let parameters: [String: Any] = ["user_name": User.shared.name.value ?? "", "fcm_token": "" ,"items": order]
        //Alamofire.request(<#T##url: URLConvertible##URLConvertible#>, method: <#T##HTTPMethod#>, parameters: <#T##Parameters?#>, encoding: <#T##ParameterEncoding#>, headers: <#T##HTTPHeaders?#>)
        //print(Alamofire.request("http://www.tritian.com/p3/api/orders", method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).debugDescription)
        return requestJSON(router: APIRouter.placeOrder(order: items, userName: User.shared.name.value ?? "", fcmToken: "")).map { (urlResponse, jsonData) -> Order in
            guard let json = jsonData as? [String: Any] else {
                throw RequestError.parsingError
            }
            return Order.init(json: json)
        }.debug()
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
    return RxAlamofire.requestJSON(router.method, router, parameters: router.result.parameters, encoding: router.encoding, headers: router.headers)
}
