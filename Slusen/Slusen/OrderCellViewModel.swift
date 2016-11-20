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

typealias OrderItemDisplayInfo = (nameText: String, amountText: String, backgroundColor: UIColor)

class OrderCellViewModel {
    let displayOrderNumber: Driver<String>
    let orderStatusImage: Driver<UIImage>
    let orderStatusText: Driver<String>
    let orderStatusBackgroundColor: Driver<UIColor>
    let orderItemsDisplayInfo: Driver<[OrderItemDisplayInfo]>

    init(order: Order) {
        displayOrderNumber = Driver.just(order.number).map {
            $0.map(String.init) ?? ""
        }
        orderStatusImage = Driver.just(order.status.image)
        orderStatusText = Driver.just(order.status.text)
        orderStatusBackgroundColor = Driver.just(order.status.backgroundColor)

        let evenCellColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
        let oddCellColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)

        orderItemsDisplayInfo = Driver.just(order.items).map { items -> [OrderItemDisplayInfo] in
            return Array(items.enumerated())
                .map({ index, item in
                    let color = index.isEven ? evenCellColor : oddCellColor
                    return OrderItemDisplayInfo(nameText: item.product.name,
                                                amountText: String(item.amount),
                                                backgroundColor: color)
                })
        }
    }
}

extension OrderStatus {
    var image: UIImage {
        switch self {
        case .pendingPayment:
            return #imageLiteral(resourceName: "shopping_cart_icon")
        case .pendingServerPaymentConfirmation, .pendingPreperation:
            return #imageLiteral(resourceName: "pending_icon")
        case .ready, .delivered:
            return #imageLiteral(resourceName: "ready_icon")
        }
    }

    var text: String {
        switch self {
        case .pendingPayment:
            return "New Order"
        case .pendingServerPaymentConfirmation, .pendingPreperation:
            return "Pending"
        case .ready:
            return "Ready"
        case .delivered:
            return "Delivered"
        }
    }

    var backgroundColor: UIColor {
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
