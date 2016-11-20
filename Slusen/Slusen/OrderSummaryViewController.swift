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
    @IBOutlet var payButton: UIButton!

    var viewModel: OrderSummaryViewModel!
    let disposeBag = DisposeBag()

    static func instantiate(orderItems: [OrderItem]) -> OrderSummaryViewController {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderSummaryViewController") as! OrderSummaryViewController
        vc.viewModel = OrderSummaryViewModel(orderItems: orderItems)
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib.init(nibName: "OrderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120

        viewModel.orderCellViewModels
            .drive(tableView.rx.items(cellIdentifier: "OrderCell", cellType: OrderTableViewCell.self)) { _, vm, cell in
            cell.viewModel = vm
        }.addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
