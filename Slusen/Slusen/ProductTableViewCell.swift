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

    @IBOutlet var rightStackView: UIStackView!

    @IBOutlet var productAmountLabel: UILabel!

    var stepperView: SlusenStepperView!

    override func awakeFromNib() {
        super.awakeFromNib()
        let slusenView = SlusenStepperView(frame: CGRect.zero)
        slusenView.translatesAutoresizingMaskIntoConstraints = false
        slusenView.addConstraint(NSLayoutConstraint(item: slusenView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 56))
        slusenView.addConstraint(NSLayoutConstraint(item: slusenView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 96))

        rightStackView.insertArrangedSubview(slusenView, at: 0)

        self.stepperView = slusenView
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    var disposeBag: DisposeBag?
    var viewModel: ProductCellViewModel? {
        didSet {
            let disposeBag = DisposeBag()

            guard let viewModel = viewModel else {
                return
            }

            viewModel.bindStepper(stepperValue: stepperView.rx.value.asObservable())

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

            self.disposeBag = disposeBag

        }
    }

    func setup(viewModel: ProductCellViewModel) {
        self.viewModel = viewModel
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.viewModel = nil
        disposeBag = nil
    }

}
