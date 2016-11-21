//
//  SideMenuBaseViewController.swift
//  Slusen
//
//  Created by Yoav Schwartz on 21/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import UIKit
import RESideMenu

class SideMenuBaseViewController: RESideMenu {


    var viewControllers: [UIViewController?] = Array(repeating: nil, count: 2)

    override func awakeFromNib() {
        super.awakeFromNib()
        self.scaleContentView = false
        self.scaleMenuView = true
        self.contentViewShadowOpacity = 1.0
        self.contentViewShadowRadius = 6.0
        self.contentViewShadowEnabled = true
        self.leftMenuViewController = self.storyboard?.instantiateViewController(withIdentifier: "LeftMenuViewController")
        self.showViewController(index: 0, animated: false)
    }

    func showViewController(index: Int, animated: Bool) {
        if let vc = viewControllers[index] {
            self.setContentViewController(vc, animated: animated)
            self.completelyDifferentName()
            return
        }

        var newVC: UIViewController
        switch index {
        case 0: newVC = self.storyboard!.instantiateViewController(withIdentifier: "MenuNavigationController")
        case 1: newVC = self.storyboard!.instantiateViewController(withIdentifier: "OrderNavigatoinController")
        default: fatalError()
        }

        viewControllers[index] = newVC
        setContentViewController(newVC, animated: animated)
        self.completelyDifferentName()
    }



    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
