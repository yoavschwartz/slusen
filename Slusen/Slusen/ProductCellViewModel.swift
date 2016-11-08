//
//  ProductTableViewCellViewModel.swift
//  Slusen
//
//  Created by Yoav Schwartz on 01/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ProductCellViewModel {

    //fileprivate let productAmount: Variable<Int> = Variable(0)
    let productName: Driver<String>
    let productDisplayPrice: Driver<String>
    let productDisplayAmount: Driver<String>
    private let _orderItem: Variable<OrderItem>
    var orderItem: Driver<OrderItem> {
        return _orderItem.asDriver()
    }
    let backgroundColor: Driver<UIColor>
    let minusButtonEnabled: Driver<Bool>
    let plusButtonEnabled: Driver<Bool>

    var disposeBag = DisposeBag()

    init(orderItem: OrderItem, row: Int) {

        _orderItem = Variable(orderItem)

        self.productName = _orderItem.asDriver().map { $0.product.name }
        productDisplayPrice = _orderItem.asDriver().map {
            guard $0.product.available else { return "Sold Out" }

            let price = Double($0.product.priceInCents) / 100
            return priceFormatter.string(from: NSNumber(value: price))!

        }

        backgroundColor = Driver
            .just(row)
            .map(ProductCellViewModel.rowBackgroundColor(row:))

        productDisplayAmount = _orderItem.asDriver().map {
            guard $0.product.available else { return "-" }
            return String($0.amount)
            }

        minusButtonEnabled =    _orderItem.asDriver().map {
            guard $0.product.available else { return false }
            return $0.amount > 0
        }

        plusButtonEnabled = _orderItem.asDriver().map { $0.product.available }
    }

    private static func rowBackgroundColor(row: Int) -> UIColor {
        let grayValue: CGFloat = (isEven(row) ? 97 : 81)/255.0
        return UIColor(red: grayValue, green: grayValue, blue: grayValue, alpha: 1.0)
    }

    func bindStepper(minusTapped: ControlEvent<Void>, plusTapped: ControlEvent<Void>) {
        Observable.of(minusTapped.map{-1}, plusTapped.map{1})
            .merge()
            .scan(_orderItem.value) { (prevOrderItem, step) -> OrderItem in
                if prevOrderItem.amount == 0 && step < 0 { return prevOrderItem }
                var prevOrderItem = prevOrderItem
                prevOrderItem.amount += step
                return prevOrderItem
            }.bindTo(_orderItem)
            .addDisposableTo(disposeBag)
    }
}

fileprivate func isEven(_ num: Int)-> Bool {
    return num % 2 == 0
}
