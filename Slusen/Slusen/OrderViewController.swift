//
//  ViewController.swift
//  Slusen
//
//  Created by Yoav Schwartz on 29/10/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import UIKit

class OrderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let onboardingVC = OnboardingViewController.initViewController(delegate: self)
        present(onboardingVC, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension OrderViewController: OnboardingViewControllerDelegate {
    func onboardingViewController(onboarding: OnboardingViewController, didEnterName name: String) {
        dismiss(animated: true, completion: nil)
        print(name)
    }
}

