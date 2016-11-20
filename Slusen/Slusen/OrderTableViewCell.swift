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

    @IBOutlet var orderNumberLabel: UILabel!
    @IBOutlet var orderStatusImage: UIImageView!
    @IBOutlet var orderStatusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var disposeBag: DisposeBag?
    var viewModel: OrderTableViewModel? {
        didSet {
            let disposeBag = DisposeBag()

            guard let viewModel = viewModel else {
                return
            }

            viewModel.displayOrderNumber.drive(orderNumberLabel.rx.text).addDisposableTo(disposeBag)
            viewModel.orderStatusTextColor
                .drive(onNext: { [unowned self] color in
                self.orderStatusLabel.textColor = color
            }).addDisposableTo(disposeBag)
            viewModel.orderStatusImage.drive(orderStatusImage.rx.image).addDisposableTo(disposeBag)
            viewModel.orderStatusText.drive(orderStatusLabel.rx.text).addDisposableTo(disposeBag)

            self.disposeBag = disposeBag

        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.viewModel = nil
        disposeBag = nil
    }

}
