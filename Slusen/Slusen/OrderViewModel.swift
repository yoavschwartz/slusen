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

typealias Order = [OrderItem]

struct OrderViewModel {
    fileprivate let products: Driver<[Product]>
    let productViewModels: Driver<[ProductCellViewModel]>
    let order: Driver<Order>
    var serverManager: ServerInterface = ServerManager.sharedInstance

    init() {
        self.products = self.serverManager.getProducts().retry(3).asDriver(onErrorJustReturn: [])
        self.productViewModels = self.products.map { (prods: [Product]) -> [ProductCellViewModel] in
            Array(prods.enumerated()).map { offset, prod in
                ProductCellViewModel(product: prod, row: offset)
            }
        }

        order = productViewModels.map { (viewModels: [ProductCellViewModel]) -> Order in
            let orderItemDrivers: [Driver<OrderItem>] = viewModels.map{ $0.orderItem }
//TODO:
        }
    }

}
