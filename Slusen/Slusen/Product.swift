//
//  Product.swift
//  Slusen
//
//  Created by Yoav Schwartz on 29/10/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation

struct Product: JSONDecodable {
    let id: Int
    let name: String
    let priceInCents: Int

    init(json: [String: Any]) {
        self.id = json["id"] as! Int
        self.name = json["name"] as! String
        self.priceInCents = json["price"] as! Int
    }
}
