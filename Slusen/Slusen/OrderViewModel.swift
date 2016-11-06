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

class OrderViewModel {

    var serverManager: ServerInterface = ServerManager.sharedInstance
    var paymentHandler: PaymentHandler = UIApplication.shared.delegate as! AppDelegate

    //Current order
    fileprivate let products: Driver<[Product]>
    fileprivate let order: Variable<[OrderItem]> = Variable([])
    let productViewModels: Driver<[ProductCellViewModel]>
    let showOrderButton: Driver<Bool>
    let buttonPriceLabelText: Driver<String>


    //Active orders
    fileprivate let activeOrders: Driver<[Order]>
    let orderViewModels: Driver<[ActiveOrderCellViewModel]>
    let showActiveOrdersTable: Driver<Bool>



    private let disposeBag = DisposeBag()

    init(orderButtonTap: Observable<Void>) {

        //Current order
        self.products = self.serverManager.getProducts().retry(3).asDriver(onErrorJustReturn: [])
        self.productViewModels = self.products.map { (prods: [Product]) -> [ProductCellViewModel] in
            Array(prods.enumerated()).map { offset, prod in
                ProductCellViewModel(product: prod, row: offset)
            }
        }

        productViewModels
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

        activeOrders = Driver.just([Order(id: 26, number: 26, items: [],status: .ready)])
        orderViewModels = activeOrders.map { $0.map(ActiveOrderCellViewModel.init) }
        showActiveOrdersTable = activeOrders.map { !$0.isEmpty }

    }

}
