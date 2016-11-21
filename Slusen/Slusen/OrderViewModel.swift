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

    let fetchIdentifiers = User.shared.rx.confirmedOrdersFetchIdentifiers

    //Active orders
    let orderViewModels: Driver<[OrderCellViewModel]>

    let disposeBag = DisposeBag()


    init() {
        self.orderViewModels = fetchIdentifiers
            .flatMapLatest { identifiers in
                return ServerManager.sharedInstance.getOrders(fetchIdentifiers: identifiers).catchErrorJustReturn([])
            }
            .map { (newOrders: [Order]) in
                newOrders.filter { $0.status != .delivered }
            }
            .map { $0.map(OrderCellViewModel.init(order:)) }
            .asDriver(onErrorJustReturn: [])
    }
}
