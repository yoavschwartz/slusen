//
//  Order.swift
//  Slusen
//
//  Created by Yoav Schwartz on 05/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Order: JSONDecodable {
    let id: Int
    let number: Int?
    let createdAt: Date?
    let priceInCents: Int?
    let items: [OrderItem]
    let fetchIdentifier: String?
    let delieveredAt: Date?
    var status: OrderStatus

    init(id: Int,
        number: Int? = nil,
        createdAt: Date? = nil,
        priceInCents: Int? = nil,
        items: [OrderItem],
        fetchIdentifier: String? = nil,
        delieveredAt: Date? = nil,
        status: OrderStatus) {
        self.id = id
        self.number = number
        self.createdAt = createdAt
        self.priceInCents = priceInCents
        self.items = items
        self.fetchIdentifier = fetchIdentifier
        self.delieveredAt = delieveredAt
        self.status = status
    }

    init(json: [String : Any]) {
        let converted = JSON(json)
        self.id = converted["id"].intValue
        self.number = converted["order_number"].intValue
        self.createdAt = ServerDateFormatter.date(from: converted["created_at"].stringValue)!
        self.priceInCents = converted["total_price"].intValue
        self.items = converted["items"].arrayValue.flatMap { $0.dictionaryObject }.map(OrderItem.init)
        self.fetchIdentifier = converted["fetch_id"].stringValue
        self.delieveredAt = converted["develivered_at"].string.flatMap(ServerDateFormatter.date(from:))
        self.status = converted["state"].string.flatMap(OrderStatus.init(rawValue:))!
    }

}

enum OrderStatus: String {
    case pendingPayment = "UNPAID"
    case pendingServerPaymentConfirmation = "pendingPaymentConfirmation"
    case pendingPreperation = "PENDING"
    case ready = "READY"
    case delivered = "DELIVERED"
}
