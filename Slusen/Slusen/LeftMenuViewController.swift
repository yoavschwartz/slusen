//
//  LeftMenuViewController.swift
//  Slusen
//
//  Created by Yoav Schwartz on 21/11/16.
//  Copyright © 2016 Slusen. All rights reserved.
//

import UIKit

class LeftMenuViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    


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

extension LeftMenuViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        switch indexPath.row {
        case 0: cell.textLabel?.text = "Menu"
        case 1: cell.textLabel?.text = "Orders"
        default: fatalError()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (self.sideMenuViewController as! SideMenuBaseViewController).showViewController(index: indexPath.row, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
