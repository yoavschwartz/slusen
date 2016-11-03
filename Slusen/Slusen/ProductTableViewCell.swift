//
//  ProductTableViewCell.swift
//  Slusen
//
//  Created by Yoav Schwartz on 01/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProductTableViewCell: UITableViewCell {

    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var productPriceLabel: UILabel!
    @IBOutlet var amountStepper: UIStepper!
    @IBOutlet var productAmountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var disposeBag = DisposeBag()

    func setup(viewModel: ProductCellViewModel) {

        viewModel.bindStepper(stepperValue: amountStepper.rx.value.asObservable())

        viewModel.productName
            .drive(productNameLabel.rx.text)
            .addDisposableTo(disposeBag)

        viewModel.productDisplayAmount
            .drive(productAmountLabel.rx.text)
            .addDisposableTo(disposeBag)

        viewModel.productDisplayPrice
            .drive(productPriceLabel.rx.text)
            .addDisposableTo(disposeBag)

        viewModel.backgroundColor.drive(onNext: { [weak self] bgColor in
            self?.backgroundColor = bgColor
        }).addDisposableTo(disposeBag)

    }

    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

}
