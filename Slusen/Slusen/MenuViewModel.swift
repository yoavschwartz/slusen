//
//  OrderViewControllerViewModel.swift
//  Slusen
//
//  Created by Yoav Schwartz on 01/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

let priceFormatter: NumberFormatter = { _ -> NumberFormatter in
    let formatter = NumberFormatter()
    formatter.currencyCode = "DKK"
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "da-DK")
    return formatter
}()

class MenuViewModel {

    var serverManager: ServerInterface = ServerManager.sharedInstance
    var paymentHandler: PaymentHandler = UIApplication.shared.delegate as! AppDelegate

    //Current order
    fileprivate let order: Variable<[OrderItem]> = Variable([])
    let productViewModels: Variable<[OrderItemCellViewModel]> = Variable([])
    let showOrderButton: Driver<Bool>
    let buttonPriceLabelText: Driver<String>
    //let reloadProductTable: Driver<Void>

    //User Name
    let shouldShowOnbaording: Driver<Bool> = User.shared.rx
        .name
        .asDriver(onErrorJustReturn: nil)
        .map { $0 == nil }

    let viewControllerTitle: Driver<String> = User.shared.rx
            .name
        .asDriver(onErrorJustReturn: nil)
            .flatMap { $0.map(Driver.just) ?? Driver.empty() }

    private let disposeBag = DisposeBag()

    init(orderButtonTap: Observable<Void>) {
        //Current order
        let products = self.serverManager.getProducts().retry(3).asDriver(onErrorJustReturn: [])
        products.map { (prods: [Product]) -> [OrderItemCellViewModel] in
            Array(prods.enumerated()).map { offset, prod in
                let orderItem = OrderItem(product: prod, amount: 0)
                return OrderItemCellViewModel(orderItem: orderItem, row: offset)
            }
        }.drive(productViewModels).addDisposableTo(disposeBag)

        productViewModels.asDriver()
            .flatMap { viewModels -> Driver<[OrderItem]> in
            let orderItems: [Driver<OrderItem>] = viewModels.map { $0.orderItem }
                return Driver.combineLatest(orderItems) { $0 }
        }
            .map{ orderItems in orderItems.filter {$0.amount > 0} }
            .distinctUntilChanged { $0 == $1 }.drive(order).addDisposableTo(disposeBag)

        showOrderButton = order.asDriver()
            .map { orderItems in
                orderItems.map { $0.amount }.reduce(0, +)
            }.map {
                $0 > 0
        }

        buttonPriceLabelText = order.asDriver()
            .map { orderItems -> Int in
            let prices = orderItems.map { $0.product.priceInCents }
            let amounts = orderItems.map { $0.amount }
            return zip(prices, amounts).map { $0.0 * $0.1 }.reduce(0, +)
            }.map { NSNumber(value: Double($0)/100.0)}
            .map({ priceFormatter.string(from: $0)!})

        let orderPayment = orderButtonTap.withLatestFrom(order.asObservable()) { (_, order:[OrderItem]) -> [OrderItem] in
            return order
            }
            .flatMapLatest { [unowned self] orderItems in
                self.serverManager.placeOrder(items: orderItems)
                .flatMap(self.payOrder)
                .catchError { _ in Observable.empty() }
            }
        .shareReplayLatestWhileConnected()

        orderPayment
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(onNext: {
                guard let fetchId = $0.fetchIdentifier else { return }
                User.shared.addConfirmedOrder(identifier: fetchId)
            })
            .addDisposableTo(disposeBag)

        orderPayment.map { _ in return () }.asDriver(onErrorJustReturn: ())
            .withLatestFrom(products) { (_, currentProducts) -> [OrderItemCellViewModel] in
            return Array(currentProducts.enumerated()).map { offset, prod in
                let orderItem = OrderItem(product: prod, amount: 0)
                return OrderItemCellViewModel(orderItem: orderItem, row: offset)
            }
            }.drive(self.productViewModels)
            .addDisposableTo(disposeBag)
        
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
