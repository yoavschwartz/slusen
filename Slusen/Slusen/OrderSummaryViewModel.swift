//
//  OrderConfirmationViewModel.swift
//  Slusen
//
//  Created by Yoav Schwartz on 20/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OrderSummaryViewModel {

    fileprivate let _orderItems: Variable<[OrderItem]>
    let orderCellViewModels: Driver<[OrderCellViewModel]>

    var payButtonTap: Observable<Void>?

    var serverManager: ServerInterface = ServerManager.sharedInstance
    var paymentHandler: PaymentHandler = UIApplication.shared.delegate as! AppDelegate

    init(orderItems: [OrderItem]) {
        let orderVar = Variable(orderItems)
        _orderItems = orderVar
        orderCellViewModels = orderVar.asDriver()
            .map({ items -> Order in
                Order(id: 0, items: items, status: .pendingPayment)
            })
            .map(OrderCellViewModel.init(order:))
            .map { [$0] }

//        let orderPayment = payButtonTap.withLatestFrom(_orderItems.asObservable()) { (_, order:[OrderItem]) -> [OrderItem] in
//            return order
//            }
//            .flatMapLatest { [unowned self] orderItems in
//                self.serverManager.placeOrder(items: orderItems)
//                    .flatMap(self.payOrder)
//                    .catchError { _ in Observable.empty() }
//            }
//            .shareReplayLatestWhileConnected()
    }

    func payOrder(order: Order) -> Observable<Order> {
        guard let price = order.priceInCents else { preconditionFailure("Should not get here with a product without a price") }

        let priceInKr = Float(price)/100.0

        return self.paymentHandler
            .makePayment(orderID: String(order.id), productPrice: priceInKr)
            .do(onNext: { payment in
                //TODO:
                //save order with payment token
            })
            .flatMap { [unowned self] payment -> Observable<Order> in
                return self.serverManager.payOrder(order: order, transactionID: payment.transactionId)
        }
        
    }
}
