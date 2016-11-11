//
//  OnboardingViewController.swift
//  Slusen
//
//  Created by Yoav Schwartz on 29/10/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OnboardingViewController: UIViewController {
    
    @IBOutlet var startButton: UIButton!
    @IBOutlet var nameTextField: UITextField! {
        didSet {
            let placeholderColor = UIColor.white.withAlphaComponent(0.7)
            nameTextField.attributedPlaceholder = NSAttributedString(string:nameTextField.placeholder ?? "", attributes: [NSForegroundColorAttributeName: placeholderColor])
        }
    }

    static func initViewController(delegate: OnboardingViewControllerDelegate) -> OnboardingViewController {
        let identifier = "OnboardingViewController"
        let onboarding = mainStoryboard.instantiateViewController(withIdentifier: identifier) as! OnboardingViewController
        onboarding.delegate = delegate
        return onboarding
    }

    weak var delegate: OnboardingViewControllerDelegate?

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        let viewModel = OnboardingViewModel(nameObservable: nameTextField.rx.text.orEmpty.asObservable())

        viewModel.startButtonEnabledDriver
            .drive(startButton.rx.isEnabled)
            .addDisposableTo(disposeBag)

        //Should go in the view model
        startButton.rx.tap.bindNext { [unowned self] _ in
            User.sharedInstance.name.value = self.nameTextField.text
            self.delegate?.onboardingViewController(onboarding: self, didEnterName: self.nameTextField.text!)
        }.addDisposableTo(disposeBag)
    }

}

protocol OnboardingViewControllerDelegate: class {
    func onboardingViewController(onboarding: OnboardingViewController, didEnterName name: String)
}
