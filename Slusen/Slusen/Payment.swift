//
//  Payment.swift
//  Slusen
//
//  Created by Yoav Schwartz on 06/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation

enum Payment {
    case success(MobilePaySuccessfulPayment)
    case cancel(orderID: String)
}

enum PaymentError: Error {
    case cancelled(orderID: String)
    case error(Error)
}
