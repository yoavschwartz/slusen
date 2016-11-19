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
}

public extension Reactive where Base: User {
    var name: Observable<String?> {
        return UserDefaults.standard.rx.observe(String.self, "userName")
    }
}

extension User: ReactiveCompatible {}
