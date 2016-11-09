//
//  OrderItemTableViewCell.swift
//  Slusen
//
//  Created by Yoav Schwartz on 01/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OrderItemTableViewCell: UITableViewCell {

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
    var viewModel: OrderItemCellViewModel? {
        didSet {
            let disposeBag = DisposeBag()
            viewModel?.disposeBag = DisposeBag()

            guard let viewModel = viewModel else {
                return
            }

            viewModel.bindStepper(minusTapped: stepperView.minusTapped, plusTapped: stepperView.plusTapped)

            let minusButtonBackgroundColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1)
            let plusButtonBackgroundColor = UIColor(red: 237/255.0, green: 28/255.0, blue: 36/255.0, alpha: 1)
            let minusButtonDisabledBackgroundColor = UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1)
            let plusButtonDisabledBackgroundColor = UIColor(red:0.53, green:0.53, blue:0.53, alpha:1.0)
            let buttonsTintColor = UIColor(red: 81/255.0, green: 81/255.0, blue: 81/255.0, alpha: 1.0)
            let buttonsDisabledTintColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)

            viewModel.minusButtonEnabled.drive(stepperView.minusButton.rx.isEnabled).addDisposableTo(disposeBag)
            viewModel.minusButtonEnabled.drive(onNext: { [unowned self] enabled in
                self.stepperView.minusButtonBackgroundColor = enabled ? minusButtonBackgroundColor : minusButtonDisabledBackgroundColor
                self.stepperView.minusButton.tintColor = enabled ? buttonsTintColor : buttonsDisabledTintColor
            }).addDisposableTo(disposeBag)

            viewModel.plusButtonEnabled.drive(stepperView.plusButton.rx.isEnabled).addDisposableTo(disposeBag)
            viewModel.plusButtonEnabled.drive(onNext: { [unowned self] enabled in
                self.stepperView.plusButtonBackgroundColor = enabled ? plusButtonBackgroundColor : plusButtonDisabledBackgroundColor
                self.stepperView.plusButton.tintColor = enabled ? buttonsTintColor : buttonsDisabledTintColor
                }).addDisposableTo(disposeBag)

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

    override func prepareForReuse() {
        super.prepareForReuse()
        self.viewModel = nil
        disposeBag = nil
    }

}
