//
//  OrderTableViewCell.swift
//  Slusen
//
//  Created by Yoav Schwartz on 05/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OrderTableViewCell: UITableViewCell {



    @IBOutlet var topView: UIView!
    @IBOutlet var orderNumberLabel: UILabel!
    @IBOutlet var orderStatusImage: UIImageView!
    @IBOutlet var orderStatusLabel: UILabel!
    @IBOutlet var totalPriceLabel: UILabel!

    @IBOutlet var itemsContainerStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var disposeBag: DisposeBag?
    var viewModel: OrderCellViewModel? {
        didSet {
            let disposeBag = DisposeBag()

            guard let viewModel = viewModel else {
                return
            }

            viewModel.displayOrderNumber.drive(orderNumberLabel.rx.text).addDisposableTo(disposeBag)
            viewModel.orderStatusBackgroundColor
                .drive(onNext: { [unowned self] color in
                self.topView.backgroundColor = color
            }).addDisposableTo(disposeBag)
            viewModel.orderStatusImage.drive(orderStatusImage.rx.image).addDisposableTo(disposeBag)
            viewModel.orderStatusText.drive(orderStatusLabel.rx.text).addDisposableTo(disposeBag)

            viewModel.orderItemsDisplayInfo.drive(onNext: { [unowned self] displayInfos in
                for view in displayInfos.map(self.orderItemView(from:)) {
                    self.itemsContainerStackView.addArrangedSubview(view)
                }
            }).addDisposableTo(disposeBag)

            self.disposeBag = disposeBag

        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.viewModel = nil
        disposeBag = nil
    }

    func orderItemView(from displayInfo: OrderItemDisplayInfo) -> UIView {
        let orderItemView = UIView()
        orderItemView.backgroundColor = displayInfo.backgroundColor
        orderItemView.translatesAutoresizingMaskIntoConstraints = false
        orderItemView.addConstraint(NSLayoutConstraint(item: orderItemView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))

        let itemNameLabel = UILabel()
        itemNameLabel.translatesAutoresizingMaskIntoConstraints = false
        itemNameLabel.font = UIFont.systemFont(ofSize: 14)
        itemNameLabel.textColor = UIColor(red:0.32, green:0.32, blue:0.32, alpha:1.0)
        itemNameLabel.text = displayInfo.nameText

        let itemAmountLabel = UILabel()
        itemAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        itemAmountLabel.font = UIFont.systemFont(ofSize: 14)
        itemAmountLabel.text = displayInfo.amountText

        let itemAmountIcon: UIImageView = UIImageView(image: #imageLiteral(resourceName: "round_number_container_gray"))
        itemAmountIcon.translatesAutoresizingMaskIntoConstraints = false

        orderItemView.addSubview(itemNameLabel)
        orderItemView.addSubview(itemAmountIcon)
        orderItemView.addSubview(itemAmountLabel)
        //image and amount together
        orderItemView.addConstraint(NSLayoutConstraint(item: itemAmountLabel, attribute: .centerX, relatedBy: .equal, toItem: itemAmountIcon, attribute: .centerX, multiplier: 1, constant: 0))
        orderItemView.addConstraint(NSLayoutConstraint(item: itemAmountLabel, attribute: .centerY, relatedBy: .equal, toItem: itemAmountIcon, attribute: .centerY, multiplier: 1, constant: 0))

        //center y
        orderItemView.addConstraint(NSLayoutConstraint(item: orderItemView, attribute: .centerY, relatedBy: .equal, toItem: itemNameLabel, attribute: .centerY, multiplier: 1, constant: 0))
        orderItemView.addConstraint(NSLayoutConstraint(item: orderItemView, attribute: .centerY, relatedBy: .equal, toItem: itemAmountIcon, attribute: .centerY, multiplier: 1, constant: 0))

        //left right margins
        orderItemView.addConstraint(NSLayoutConstraint(item: itemNameLabel, attribute: .leading, relatedBy: .equal, toItem: orderItemView, attribute: .leading, multiplier: 1, constant: 16))
        orderItemView.addConstraint(NSLayoutConstraint(item: orderItemView, attribute: .right, relatedBy: .equal, toItem: itemAmountIcon, attribute: .right, multiplier: 1, constant: 16))






        return orderItemView
    }

}
