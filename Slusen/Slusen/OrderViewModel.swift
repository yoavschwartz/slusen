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
    let orderViewModels: Driver<[OrderCellViewModel]>

    let disposeBag = DisposeBag()


    init() {
        //TODO: Refresh on viewWillAppear

        let notificationObserver = NotificationCenter.default.rx.notification(.orderStatusChange).withLatestFrom(User.shared.rx.confirmedOrdersFetchIdentifiers)
        let fetchIdentifiersObserver = User.shared.rx.confirmedOrdersFetchIdentifiers



        self.orderViewModels = Observable.of(notificationObserver, fetchIdentifiersObserver)
            .merge()
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
