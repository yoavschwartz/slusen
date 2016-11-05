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
    let number: Int
    var status: OrderStatus
}

enum OrderStatus {
    case pendingPayment
    case pendingDelivery
    case ready
    case delivered
}
