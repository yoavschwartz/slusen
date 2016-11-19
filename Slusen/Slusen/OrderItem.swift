//
//  OrderItem.swift
//  Slusen
//
//  Created by Yoav Schwartz on 01/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation

struct OrderItem {
    let product: Product
    var amount: Int
}

extension OrderItem: JSONDecodable {
    init(json: [String : Any]) {
        self.amount = json["quantity"] as! Int
        self.product = Product.init(json: json["product"] as! [String: Any])
    }
}

extension OrderItem: Equatable {}

func == (lhs: OrderItem, rhs: OrderItem) -> Bool {
    return lhs.product == rhs.product &&
        lhs.amount == rhs.amount
}
