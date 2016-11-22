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
    fileprivate let _orderSuccess: Variable<Void> = Variable()
    var orderSuccess: Driver<Void> {
        return _orderSuccess.asDriver().skip(1)
    }

    fileprivate var payButtonTap: Observable<Void>?

    var serverManager: ServerInterface = ServerManager.sharedInstance
    var paymentHandler: PaymentHandler = UIApplication.shared.delegate as! AppDelegate

    let disposeBag = DisposeBag()

    init(orderItems: [OrderItem]) {
        let orderVar = Variable(orderItems)
        _orderItems = orderVar
        orderCellViewModels = orderVar.asDriver()
            .map({ items -> Order in
                Order(id: 0, items: items, status: .pendingPayment)
            })
            .map(OrderCellViewModel.init(order:))
            .map { [$0] }
    }

    func bindPayButtonTap(_ payButtonTap: Observable<Void>) {
        self.payButtonTap = payButtonTap

        let newOrderObservable = payButtonTap.withLatestFrom(_orderItems.asObservable()) { (_, order:[OrderItem]) -> [OrderItem] in
            return order
            }
            .flatMapLatest { [unowned self] orderItems in
                self.serverManager
                    .placeOrder(items: orderItems)
                    .flatMap(self.payOrder)
                    .catchError { error in
                        print(error)
                        return Observable.empty()
                }
            }.shareReplayLatestWhileConnected()

        newOrderObservable.subscribe(onNext: { order in
            guard let fetchIdentifier = order.fetchIdentifier else { return }
            User.shared.addConfirmedOrder(identifier: fetchIdentifier)
        }).addDisposableTo(disposeBag)

        newOrderObservable.subscribe(onNext: { [unowned self] _ in
            self._orderSuccess.value = ()
        }).addDisposableTo(disposeBag)
    }

    func payOrder(order: Order) -> Observable<Order> {
        guard let price = order.priceInCents else { preconditionFailure("Should not get here with a product without a price") }

        let priceInKr = Float(price)/100.0

        return self.paymentHandler
            .makePayment(orderID: String(order.id), productPrice: priceInKr)
            .do(onNext: { payment in
                //TODO: save order with payment token
            })
            .flatMap { [unowned self] payment -> Observable<Order> in
                return self.serverManager.payOrder(order: order, transactionID: payment.transactionId)
        }
        
    }
}
