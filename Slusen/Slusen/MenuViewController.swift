//
//  ViewController.swift
//  Slusen
//
//  Created by Yoav Schwartz on 29/10/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MenuViewController: UIViewController {


    @IBOutlet var tableView: UITableView!
    var viewModel: MenuViewModel!

    let disposeBag = DisposeBag()

    @IBOutlet var bottomButtonContainer: UIView!
    @IBOutlet var makeOrderButton: UIButton!
    @IBOutlet var buttonPriceLabel: UILabel!
    @IBOutlet var buttonAmountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: clean view on order


        self.viewModel = MenuViewModel(orderButtonTap: makeOrderButton.rx.tap.asObservable())
        setupOrderButton()

        viewModel.productViewModels.asDriver().drive(self.tableView.rx.items(cellIdentifier: "productCell", cellType: OrderItemTableViewCell.self)) { row, vm, cell in
            cell.viewModel = vm
        }.addDisposableTo(disposeBag)

        viewModel.navigateToViewController.drive(onNext: { [unowned self] vc in
            self.show(vc, sender: self)
            }).addDisposableTo(disposeBag)
        
    }

    func setupOrderButton() {

        view.addSubview(bottomButtonContainer)
        bottomButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        let viewDict: [String: UIView] = ["view": view, "buttonContainer": bottomButtonContainer]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[buttonContainer]|", options: NSLayoutFormatOptions(), metrics: nil, views: viewDict))

        let bottomViewHeight: CGFloat = 48

        bottomButtonContainer.addConstraint(NSLayoutConstraint(item: bottomButtonContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: bottomViewHeight))


        let hideConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: bottomButtonContainer, attribute: .top, multiplier: 1, constant: 0)
        hideConstraint.priority = 750
        view.addConstraint(hideConstraint)


        let showConstraint = NSLayoutConstraint(item: bottomButtonContainer, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        showConstraint.priority = 1000
        view.addConstraint(showConstraint)
        NSLayoutConstraint.deactivate([showConstraint])

        viewModel.showOrderButton.drive(onNext: { [unowned self] show in
            if show {
                NSLayoutConstraint.activate([showConstraint])
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomViewHeight, right: 0)
            } else {
                NSLayoutConstraint.deactivate([showConstraint])
                self.tableView.contentInset = UIEdgeInsets()
            }

            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        }).addDisposableTo(disposeBag)

        viewModel.buttonPriceLabelText
            .drive(buttonPriceLabel.rx.text)
            .addDisposableTo(disposeBag)

        viewModel.buttonAmountLabelText
            .drive(buttonAmountLabel.rx.text)
            .addDisposableTo(disposeBag)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.shouldShowOnbaording.flatMap {
            $0 ? Driver.just() : Driver.empty()
            }.drive(onNext: { [unowned self] _ in
                let onboardingVC = OnboardingViewController.initViewController(delegate: self)
                self.present(onboardingVC, animated: true, completion: nil)
            }).addDisposableTo(disposeBag)
    }

    @IBAction func sideMenuButtonPressed(_ sender: AnyObject) {
        showSideMenu(sender: self)
    }

    deinit {
        print("MenuViewControllerDeinited")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension MenuViewController: SideMenuShower {}

extension MenuViewController: OnboardingViewControllerDelegate {
    func onboardingViewController(onboarding: OnboardingViewController, didEnterName name: String) {
        dismiss(animated: true, completion: nil)
        print(name)
    }
}
