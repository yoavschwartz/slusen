//
//  slusenStepper.swift
//  Slusen
//
//  Created by Yoav Schwartz on 04/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SlusenStepperView: UIView {

    let minusButton = UIButton(type: UIButtonType.system)
    let plusButton = UIButton(type: UIButtonType.system)

    var minusTapped: ControlEvent<Void> {
        return minusButton.rx.tap
    }

    var plusTapped: ControlEvent<Void> {
        return plusButton.rx.tap
    }

    fileprivate let _value: Variable<Int> = Variable(0)

    var minusButtonBackgroundColor: UIColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1) {
        didSet {
            minusButton.backgroundColor = minusButtonBackgroundColor
        }
    }

    var plusButtonBackgroundColor: UIColor = UIColor(red: 237/255.0, green: 28/255.0, blue: 36/255.0, alpha: 1) {
        didSet {
            plusButton.backgroundColor = plusButtonBackgroundColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func setupViews() {
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(minusButton)
        addSubview(plusButton)
        minusButton.backgroundColor = minusButtonBackgroundColor
        plusButton.backgroundColor = plusButtonBackgroundColor
        minusButton.setImage(#imageLiteral(resourceName: "minus_button_icon"), for: .normal)
        plusButton.setImage(#imageLiteral(resourceName: "plus_button_icon"), for: .normal)

        minusButton.tintColor = UIColor(red: 81/255.0, green: 81/255.0, blue: 81/255.0, alpha: 1.0)
        plusButton.tintColor = .white//UIColor(red: 81/255.0, green: 81/255.0, blue: 81/255.0, alpha: 1.0)




    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let viewsDict: [String: UIView] = ["minusButton": minusButton, "plusButton": plusButton]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[minusButton]-0-[plusButton(==minusButton)]|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[minusButton]|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[plusButton]|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict))

        let minusPath = UIBezierPath(roundedRect:minusButton.bounds,
                                     byRoundingCorners:[.topLeft, .bottomLeft],
                                     cornerRadii: CGSize(width: 5, height:  5))

        let minusMaskLayer = CAShapeLayer()

        minusMaskLayer.path = minusPath.cgPath
        minusButton.layer.mask = minusMaskLayer

        let plusPath = UIBezierPath(roundedRect:plusButton.bounds,
                                    byRoundingCorners:[.topRight, .bottomRight],
                                    cornerRadii: CGSize(width: 5, height:  5))

        let plusMaskLayer = CAShapeLayer()

        plusMaskLayer.path = plusPath.cgPath
        plusButton.layer.mask = plusMaskLayer
    }
}
