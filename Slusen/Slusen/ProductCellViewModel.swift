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

    fileprivate let _productAmount: Variable<Int> = Variable(0)
    let productName: Driver<String>
    let productDisplayPrice: Driver<String>
    let productDisplayAmount: Driver<String>
    let orderItem: Driver<OrderItem>
    let backgroundColor: Driver<UIColor>
    let minusButtonEnabled: Driver<Bool>
    let plusButtonEnabled: Driver<Bool> = Driver.just(true)

    var disposeBag = DisposeBag()

    init(product: Product, row: Int) {

        productName = Driver.just(product.name)
        productDisplayPrice = Driver.just(product.priceInCents)
            .map { Double($0)/100 }
            .map { String($0) + " kr." }
        backgroundColor = Driver
            .just(row)
            .map(isEven)
            .map {
                let grayValue: CGFloat = ($0 ? 97 : 81)/255.0
                return UIColor(red: grayValue, green: grayValue, blue: grayValue, alpha: 1.0)
        }

        orderItem = Driver.combineLatest(Driver.just(product), _productAmount.asDriver()) { (prod: Product, amount: Int) -> OrderItem in
            OrderItem(product: prod, amount: amount)
        }

        productDisplayAmount = _productAmount.asDriver().map(String.init)

        minusButtonEnabled = _productAmount.asDriver().map { $0 > 0 }
    }

    func bindStepper(minusTapped: ControlEvent<Void>, plusTapped: ControlEvent<Void>) {
        minusTapped.subscribe(onNext: { [unowned self] _ in
            guard self._productAmount.value > 0 else { return }
            self._productAmount.value -= 1
        }).addDisposableTo(disposeBag)

        plusTapped.subscribe(onNext: { [unowned self] _ in
            self._productAmount.value += 1
            }).addDisposableTo(disposeBag)
    }
}

fileprivate func isEven(_ num: Int)-> Bool {
    return num % 2 == 0
}
