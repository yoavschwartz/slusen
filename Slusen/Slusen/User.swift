//
//  User.swift
//  Slusen
//
//  Created by Yoav Schwartz on 11/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class User {
    static let shared = User()


    var name: String? {
        get {
            return UserDefaults.standard.string(forKey: "userName")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "userName")
        }
    }

    var confirmedOrdersFetchIdentifiers: [String] {
        return UserDefaults.standard.array(forKey: "confirmedOrdersFetchIdentifiers") as? [String] ?? []
    }

    func addConfirmedOrder(identifier: String) {
        var currentOrders = UserDefaults.standard.array(forKey: "confirmedOrdersFetchIdentifiers") ?? []
        currentOrders.append(identifier)
        UserDefaults.standard.setValue(currentOrders, forKey: "confirmedOrdersFetchIdentifiers")
    }
}

public extension Reactive where Base: User {
    var name: Observable<String?> {
        return UserDefaults.standard.rx.observe(String.self, "userName")
    }

    var confirmedOrdersFetchIdentifiers: Observable<[String]> {
        return UserDefaults.standard.rx
            .observe([String].self, "confirmedOrdersFetchIdentifiers")
            .map{ $0 ?? [] }
    }
}

extension User: ReactiveCompatible {}
