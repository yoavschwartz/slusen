//
//  OrderCellViewModel.swift
//  Slusen
//
//  Created by Yoav Schwartz on 05/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OrderTableViewModel {
    let displayOrderNumber: Driver<String>
    let orderStatusImage: Driver<UIImage>
    let orderStatusText: Driver<String>
    let orderStatusTextColor: Driver<UIColor>

    init(order: Order) {
        displayOrderNumber = Driver.just(order.number).map {
            $0.map(String.init) ?? ""
        }
        orderStatusImage = Driver.just(order.status.image)
        orderStatusText = Driver.just(order.status.text)
        orderStatusTextColor = Driver.just(order.status.textColor)
    }
}

extension OrderStatus {
    var image: UIImage {
        switch self {
        case .delivered:
            return #imageLiteral(resourceName: "delivered_icon")
        case .pendingPayment, .pendingServerPaymentConfirmation, .pendingPreperation:
            return #imageLiteral(resourceName: "pending_icon")
        case .ready:
            return #imageLiteral(resourceName: "ready_icon")
        }
    }

    var text: String {
        switch self {
        case .delivered:
            return "Delivered"
        case .pendingPayment, .pendingServerPaymentConfirmation, .pendingPreperation:
            return "Pending"
        case .ready:
            return "Ready"
        }
    }

    var textColor: UIColor {
        switch self {
        case .delivered:
            return UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.0)
        case .pendingPayment, .pendingServerPaymentConfirmation, .pendingPreperation:
            return UIColor(red:0.79, green:0.71, blue:0.07, alpha:1.0)
        case .ready:
            return UIColor(red:0.58, green:0.79, blue:0.07, alpha:1.0)
        }
    }
}
