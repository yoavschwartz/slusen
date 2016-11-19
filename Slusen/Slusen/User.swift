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

class User {
    static let shared = User()


    let name: Variable<String?> = Variable(UserDefaults.standard.string(forKey: "userName"))

    let disposeBag = DisposeBag()

    init() {
        name.asDriver().skip(1).drive(onNext: { newValue in
            UserDefaults.standard.setValue(newValue, forKey: "userName")
            }).addDisposableTo(disposeBag)
    }
}
