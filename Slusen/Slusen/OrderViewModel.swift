//
//  OrderViewModel.swift
//  Slusen
//
//  Created by Yoav Schwartz on 20/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OrdersViewModel {

    //Active orders
    fileprivate let activeOrders: Variable<[Order]> = Variable([])
    let orderViewModels: Driver<[ActiveOrderCellViewModel]>
    let showActiveOrdersTable: Driver<Bool>


    init() {
        orderViewModels = activeOrders.asDriver().map { $0.map(ActiveOrderCellViewModel.init) }
        showActiveOrdersTable = activeOrders.asDriver().map { !$0.isEmpty }
    }
}
