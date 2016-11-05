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

class OrderViewController: UIViewController {


    @IBOutlet var containerStackView: UIStackView!

    @IBOutlet var tableView: UITableView!
    @IBOutlet var activeOrdersTableView: UITableView!
    @IBOutlet var activeOrdersTableViewHeightConstraint: NSLayoutConstraint!
    
    var viewModel: OrderViewModel!

    let disposeBag = DisposeBag()
    var serverManager: ServerInterface = ServerManager.sharedInstance

    @IBOutlet var bottomButtonContainer: UIView!
    @IBOutlet var makeOrderButton: UIButton!
    @IBOutlet var buttonPriceLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = OrderViewModel(orderButtonTap: makeOrderButton.rx.tap.asObservable())
        setupOrderButton()

        viewModel.productViewModels.drive(self.tableView.rx.items(cellIdentifier: "productCell", cellType: ProductTableViewCell.self)) { row, vm, cell in
            cell.viewModel = vm
        }.addDisposableTo(disposeBag)

        viewModel.orderViewModels.drive(self.activeOrdersTableView.rx.items(cellIdentifier: "activeOrderCell", cellType: ActiveOrderTableViewCell.self)) { row, vm, cell in
            cell.viewModel = vm
            }.addDisposableTo(disposeBag)

        viewModel.orderViewModels.map { $0.count }
            .map { numberOfActiveOrders -> CGFloat in
            let activeOrderCellHeight: CGFloat = 44
            let activeOrdersTableviewTopViewHeight: CGFloat = 20
            let bottomPaddingHeight: CGFloat = 20
            return (CGFloat(numberOfActiveOrders) * activeOrderCellHeight) + activeOrdersTableviewTopViewHeight + bottomPaddingHeight
            }.drive(onNext: { [unowned self] height in
                self.activeOrdersTableViewHeightConstraint.constant = height
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
            })
            .addDisposableTo(disposeBag)

        viewModel.showActiveOrdersTable
            .map {!$0}
            .drive(onNext: { [unowned self] show in
                UIView.animate(withDuration: 0.3){
                    self.activeOrdersTableView.isHidden = show //or false
                }
            })
            .addDisposableTo(disposeBag)





        // Do any additional setup after loading the view, typically from a nib.
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


    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //let onboardingVC = OnboardingViewController.initViewController(delegate: self)
        //present(onboardingVC, animated: true, completion: nil)
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

