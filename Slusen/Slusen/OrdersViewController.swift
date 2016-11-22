//
//  OrdersTableViewController.swift
//  Slusen
//
//  Created by Yoav Schwartz on 20/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OrdersViewController: UIViewController {


    @IBOutlet var tableView: UITableView!

    var viewModel:  OrdersViewModel!
    let viewWillAppearSubject: PublishSubject<Void> = PublishSubject()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshController = UIRefreshControl()
        let refreshObservable: Observable<Void> = refreshController.rx.controlEvent(.valueChanged)
            .map { _ in return () }
            .asObservable()
        self.viewModel = OrdersViewModel(viewWillAppear: viewWillAppearSubject.asObservable(),
                                         refreshControlEvent: refreshObservable)

        tableView.addSubview(refreshController)

        viewModel.loadingData
            .filter { $0 == false }
            .drive(refreshController.rx.refreshing)
            .addDisposableTo(disposeBag)

        tableView.register(UINib.init(nibName: "OrderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120

        viewModel.orderViewModels.drive(tableView.rx.items(cellIdentifier: "OrderCell", cellType:  OrderTableViewCell.self)) { row, vm, cell in
            cell.viewModel = vm
            }.addDisposableTo(disposeBag)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.onNext()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sideMenuButtonPressed(_ sender: AnyObject) {
        showSideMenu(sender: self)
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

extension OrdersViewController: SideMenuShower {}
