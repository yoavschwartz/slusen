//
//  OrderConfirmationViewController.swift
//  Slusen
//
//  Created by Yoav Schwartz on 20/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OrderSummaryViewController: UIViewController {


    @IBOutlet var tableView: UITableView!
    @IBOutlet var payButton: UIButton! {
        didSet {
            viewModel.bindPayButtonTap(payButton.rx.tap.asObservable())
        }
    }

    var viewModel: OrderSummaryViewModel!
    let disposeBag = DisposeBag()

    static func instantiate(viewModel: OrderSummaryViewModel) -> OrderSummaryViewController {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderSummaryViewController") as! OrderSummaryViewController
        vc.viewModel = viewModel
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        payButton.layer.cornerRadius = 4

        tableView.register(UINib.init(nibName: "OrderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120

        viewModel.payButtonEnabled
            .drive(self.payButton.rx.isEnabled)
            .addDisposableTo(disposeBag)

        viewModel.orderCellViewModels
            .drive(tableView.rx.items(cellIdentifier: "OrderCell", cellType: OrderTableViewCell.self)) { _, vm, cell in
            cell.viewModel = vm
        }.addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
