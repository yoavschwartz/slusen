//
//  PaymentHandler.swift
//  Slusen
//
//  Created by Yoav Schwartz on 06/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import RxSwift

protocol PaymentHandler {
    func makePayment(orderID: String, productPrice: Float) -> Observable<Payment>
}
