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
    private let fetchIndicator: ActivityIndicator
    var loadingData: Driver<Bool> {
        return self.fetchIndicator.asDriver()
    }

    let disposeBag = DisposeBag()


    init(viewWillAppear: Observable<Void> ,refreshControlEvent: Observable<Void>) {

        let refresh = refreshControlEvent.withLatestFrom(User.shared.rx.confirmedOrdersFetchIdentifiers)

        let viewAppearing = viewWillAppear.withLatestFrom(User.shared.rx.confirmedOrdersFetchIdentifiers)

        viewAppearing.subscribe(onNext: {
            _ in UIApplication.shared.applicationIconBadgeNumber = 0
        }).addDisposableTo(disposeBag)

        let notificationObserver = NotificationCenter.default.rx.notification(.orderStatusChange).withLatestFrom(User.shared.rx.confirmedOrdersFetchIdentifiers)
        let fetchIdentifiersObserver = User.shared.rx.confirmedOrdersFetchIdentifiers

        let fetch = ActivityIndicator()

        self.orderViewModels = Observable.of(notificationObserver, fetchIdentifiersObserver, refresh, viewAppearing)
            .merge()
            .debug()
            .flatMapLatest { identifiers in
                return ServerManager.sharedInstance.getOrders(fetchIdentifiers: identifiers).catchErrorJustReturn([]).trackActivity(fetch)
            }
            .map { (newOrders: [Order]) in
                newOrders.filter { $0.status != .delivered }
            }
            .map { $0.map(OrderCellViewModel.init(order:)) }
            .asDriver(onErrorJustReturn: [])

        self.fetchIndicator = fetch

    }
}
