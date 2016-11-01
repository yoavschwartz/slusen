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

struct ProductTableViewCellViewModel {

    let productName: Driver<String>
    let productDisplayPrice: Driver<String>
    let productDisplayAmount: Driver<String>
    let backgroundColor: Driver<UIColor>

    init(product: Product, indexPath: IndexPath,
         stepperValue: Observable<Double>
        ) {

        productName = Driver.just(product.name)
        productDisplayPrice = Driver.just(product.priceInCents)
            .map { Double($0)/100 }
            .map { String($0) + " kr." }
        productDisplayAmount = stepperValue
            .asDriver(onErrorJustReturn: 0)
            .map(String.init)
        backgroundColor = Driver
            .just(indexPath)
            .map { $0.row }
            .map(isEven)
            .map {
                let grayValue: CGFloat = ($0 ? 97 : 81)/255.0
                return UIColor(red: grayValue, green: grayValue, blue: grayValue, alpha: 1.0)
        }

}

fileprivate func isEven(_ num: Int)-> Bool {
    return num % 2 == 0
}
