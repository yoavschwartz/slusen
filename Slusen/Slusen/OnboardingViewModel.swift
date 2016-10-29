//
//  OnboardingViewModel.swift
//  Slusen
//
//  Created by Yoav Schwartz on 29/10/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct OnboardingViewModel {
    let startButtonEnabledDriver: Driver<Bool>

    private let disposeBag = DisposeBag()

    init(nameObservable: (Observable<String>)) {
        self.startButtonEnabledDriver = nameObservable.asDriver(onErrorJustReturn: "")
            .map { return !$0.isEmpty }
    }
}
