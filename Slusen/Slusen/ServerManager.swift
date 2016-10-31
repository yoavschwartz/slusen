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

}

class ServerManager {
    func getProducts() -> Observable<[Product]> {
        return requestJSON(router: APIRouter.getProducts).map { (urlResponse, jsonData) -> [Product] in
            guard let json = jsonData as? [String: Any],
            let prodcuts = json["products"] as? [[String: Any]]
                else { throw RequestError.parsingError }
            return prodcuts.map(Product.init)
        }
    }
}

enum RequestError: Error {
    case parsingError
}

fileprivate func requestJSON(router: APIRouter) -> Observable<(HTTPURLResponse, Any)> {
    return RxAlamofire.requestJSON(router.method, router, parameters: router.result.parameters, headers: router.headers)
}
