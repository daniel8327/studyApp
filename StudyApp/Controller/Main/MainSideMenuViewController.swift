//
//  MainSideMenuViewController.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/12.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit

class MainSideMenuViewController: UIViewController {

    let menus: [String] = ["내정보", "앱버전", "로그아웃"]
    override func viewDidLoad() {
        super.viewDidLoad()

        let tableView = UITableView()
        
        //print("UIApplication.shared.keyWindow?.safeAreaInsets.top \(UIApplication.shared.keyWindow?.safeAreaInsets.top )")
        tableView.frame = self.view.frame
        
        self.view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SideMenuCell")
        
    }
}

extension MainSideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = menus[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 2 {

            let loginHistory = CoreDataManager.shared.getLogin()
            
            CoreDataManager.shared.deleteLogin(userEmail: loginHistory.first!.user_email!) { isSuccess in

                self.present(UIStoryboard(name: "Sign", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController"), animated: true, completion: nil)
            }
        } else {
            Common.GF_TOAST(self.view, menus[indexPath.row])
        }
    }
}
