//
//  ViewController+SideMenuPresenter.swift
//  Slusen
//
//  Created by Yoav Schwartz on 21/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import Foundation
import UIKit
import RESideMenu


protocol SideMenuShower {
    func showSideMenu(sender: Any?)
}

extension SideMenuShower where Self:UIViewController {
    func showSideMenu(sender: Any?) {
        self.sideMenuViewController.presentLeftMenuViewController()
    }
}
