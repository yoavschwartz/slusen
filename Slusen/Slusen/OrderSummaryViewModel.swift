//
//  OrderConfirmationViewModel.swift
//  Slusen
//
//  Created by Yoav Schwartz on 20/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OrderSummaryViewModel {

    fileprivate let _orderItems: Variable<[OrderItem]>
    let orderCellViewModels: Driver<[OrderCellViewModel]>

    fileprivate var payButtonTap: Observable<Void>?

    var serverManager: ServerInterface = ServerManager.sharedInstance
    var paymentHandler: PaymentHandler = UIApplication.shared.delegate as! AppDelegate
    weak var delegate: OrderSummaryDelegate?

    let disposeBag = DisposeBag()

    init(orderItems: [OrderItem], delegate: OrderSummaryDelegate) {
        self.delegate = delegate
        let orderVar = Variable(orderItems)
        _orderItems = orderVar
        orderCellViewModels = orderVar.asDriver()
            .map({ items -> Order in
                Order(id: 0, items: items, status: .pendingPayment)
            })
            .map(OrderCellViewModel.init(order:))
            .map { [$0] }
    }

    func bindPayButtonTap(_ payButtonTap: Observable<Void>) {
        self.payButtonTap = payButtonTap

        let newOrderObservable = payButtonTap.withLatestFrom(_orderItems.asObservable()) { (_, order:[OrderItem]) -> [OrderItem] in
            return order
            }
            .flatMapLatest { [unowned self] orderItems in
                self.placeOrder(items: orderItems)
                    .flatMap { order in
                        self.processPayment(for: order)
                            .flatMap { payment in
                                self.upload(payment: payment, for: order)
                        }
                    }
                    .catchError { [weak self] error in
                        self?.delegate?.orderCancelled()
                        return Observable.empty()
                }
            }.shareReplayLatestWhileConnected()

        newOrderObservable.subscribe(onNext: { [weak self] order in
            guard let fetchIdentifier = order.fetchIdentifier else { return }
            User.shared.addConfirmedOrder(identifier: fetchIdentifier)
            self?.delegate?.orderSuccessful()
        }).addDisposableTo(disposeBag)
    }

    func placeOrder(items: [OrderItem]) -> Observable<Order> {
        return serverManager.placeOrder(items: items)
            .retryWhen({ (errorObservable: Observable<Error>) -> Observable<Order> in
                errorObservable.flatMap({ error in
                    return promptFor(title: "An error has occoured", message: error.localizedDescription, cancelAction: RetryResult.cancel, actions: [RetryResult.retry])
                        .flatMap { action -> Observable<Order> in
                            switch action {
                            case .retry:
                                return self.placeOrder(items: items)
                            case .cancel:
                                return Observable.error(error)
                            }
                    }
                })
        })
    }

    func processPayment(for order: Order) -> Observable<MobilePaySuccessfulPayment> {
        guard let price = order.priceInCents else { preconditionFailure("Should not get here with a product without a price") }

        let priceInKr = Float(price)/100.0

        return self.paymentHandler
            .makePayment(orderID: String(order.id), productPrice: priceInKr)
            .retryWhen({ (errorObservable: Observable<Error>) -> Observable<MobilePaySuccessfulPayment> in
                return errorObservable.flatMap({ error -> Observable<MobilePaySuccessfulPayment> in
                    guard let e = error as? PaymentError else { return Observable.error(error) }
                    switch e {
                    case .cancelled(_): return Observable.error(error)
                    case .error(let mobilePayError):
                        let title = mobilePayError.localizedDescription
                        let message = ((mobilePayError as NSError).userInfo[NSLocalizedRecoverySuggestionErrorKey] as? String) ?? ""
                        return promptFor(title: title, message: message, cancelAction: RetryResult.cancel, actions: [RetryResult.retry])
                            .flatMap { action -> Observable<MobilePaySuccessfulPayment> in
                                switch action {
                                case .retry:
                                    return self.processPayment(for: order)
                                case .cancel:
                                    return Observable.error(error)
                                }
                        }
                    }
                })
            })
    }

    func upload(payment: MobilePaySuccessfulPayment, for order: Order ) -> Observable<Order> {
        return self.serverManager
            .payOrder(order: order, transactionID: payment.transactionId)
            .retry(3)
            .retryWhen({ (errorObservable: Observable<Error>) -> Observable<Order> in
                return errorObservable.flatMap({ error -> Observable<Order> in
                    let message = "Your payment was confirmed but could not be upload, please retry or consult the bar staff to process your order #\(order.number) manualy.\n error: \(error.localizedDescription)"
                    return promptFor(title: "An error has occoured",
                                     message: message
                        , cancelAction: DestructiveResult.consultStaff, actions: [DestructiveResult.retry])
                        .flatMap { action -> Observable<Order> in
                            switch action {
                            case .retry:
                                return self.upload(payment: payment, for: order)
                            case .consultStaff:
                                return Observable.error(error)
                            }
                    }
                })
            })
    }
}

protocol UIAlertActionConvertible: CustomStringConvertible {
    var actionStyle: UIAlertActionStyle { get }
}

enum RetryResult {
    case retry
    case cancel
}

extension RetryResult : UIAlertActionConvertible {
    internal var actionStyle: UIAlertActionStyle {
        switch self {
        case .retry:
            return .default
        case .cancel:
            return .cancel
        }
    }

    var description: String {
        switch self {
        case .retry:
            return "Retry"
        case .cancel:
            return "Cancel"
        }
    }
}

enum DestructiveResult {
    case retry
    case consultStaff
}

extension DestructiveResult : UIAlertActionConvertible {
    internal var actionStyle: UIAlertActionStyle {
        switch self {
        case .retry:
            return .default
        case .consultStaff:
            return .destructive
        }
    }

    var description: String {
        switch self {
        case .retry:
            return "Retry"
        case .consultStaff:
            return "Consult Staff"
        }
    }
}

protocol OrderSummaryDelegate: class {
    func orderCancelled()
    func orderSuccessful()
}

func promptFor<Action : UIAlertActionConvertible>(title: String, message: String, cancelAction: Action, actions: [Action]) -> Observable<Action> {
        return Observable.create { observer in
            let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: cancelAction.description, style: cancelAction.actionStyle) { _ in
                observer.on(.next(cancelAction))
                observer.onCompleted()
            })

            for action in actions {
                alertView.addAction(UIAlertAction(title: action.description, style: action.actionStyle) { _ in
                    observer.on(.next(action))
                    observer.onCompleted()
                })
            }

            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alertView, animated: true, completion: nil)

            return Disposables.create {
                alertView.dismiss(animated:false, completion: nil)
            }
        }
}
