//
//  Order.swift
//  Slusen
//
//  Created by Yoav Schwartz on 05/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation

struct Order {
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
}

enum OrderStatus {
    case pendingPayment
    case pendingServerPaymentConfirmation
    case pendingPreperation
    case ready
    case delivered
}
