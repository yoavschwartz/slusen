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

    //Current order
    fileprivate let order: Variable<[OrderItem]> = Variable([])
    let productViewModels: Variable<[OrderItemCellViewModel]> = Variable([])
    let showOrderButton: Driver<Bool>
    let buttonPriceLabelText: Driver<String>
    let buttonAmountLabelText: Driver<String>

    fileprivate let _orderFinishedSuccess: PublishSubject<Bool> = PublishSubject()
    var orderFinishedSuccess: Driver<Bool> {
        return _orderFinishedSuccess.asDriver(onErrorDriveWith: Driver.empty())
    }

    let orderStatusUpdate: Driver<Void> = NotificationCenter.default
        .rx.notification(.orderStatusChange, object: nil)
        .asDriver(onErrorDriveWith: Driver.empty())
        .map { _ in return () }

    //Navigation
    var navigateToViewController: Driver<UIViewController>? = nil

    //User Name
    let shouldShowOnbaording: Driver<Bool> = User.shared.rx
        .name
        .asDriver(onErrorJustReturn: nil)
        .map { $0 == nil }

    private let disposeBag = DisposeBag()

    init(orderButtonTap: Observable<Void>) {
        //Current order

        let firstProducts = self.serverManager.getProducts().retry(3)
        let refreshProducts = _orderFinishedSuccess.asObservable()
            .flatMap { _ in ServerManager.sharedInstance.getProducts().retry(3)}

        let products = Observable.of(firstProducts, refreshProducts).merge().asDriver(onErrorJustReturn: [])
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

        buttonAmountLabelText = order.asDriver().map { orderItems in
            let amount = orderItems.map { $0.amount }.reduce(0, +)
            return String(amount)
        }

        navigateToViewController = orderButtonTap
            .withLatestFrom(order.asObservable())
            .asDriver(onErrorDriveWith: Driver.empty())
            .map { orderItems -> OrderSummaryViewController in
                OrderSummaryViewController.instantiate(viewModel: OrderSummaryViewModel(orderItems: orderItems, delegate: self))
        }

        
    }

}

extension MenuViewModel: OrderSummaryDelegate {
    func orderSuccessful() {
        _orderFinishedSuccess.onNext(true)
    }

    func orderCancelled() {
        _orderFinishedSuccess.onNext(false)
    }
}
