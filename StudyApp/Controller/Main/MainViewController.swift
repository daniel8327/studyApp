//
//  MainViewController.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/09.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setSideMenuButton()    }
    
    func setSideMenuButton() {
        
        if let revealVC = self.revealViewController() {
            
            let btn = UIBarButtonItem()
            btn.image = UIImage(named: "menu.png")
            btn.target = revealVC
            btn.action = #selector(revealVC.revealToggle(_:))
            
            self.navigationItem.leftBarButtonItem = btn
            
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
    }
    
    //화면 여백 터치 시 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if self.revealViewController()?.frontViewPosition.rawValue == 4 {
            //print("self.revealViewController()?.frontViewPosition.rawValue : \(self.revealViewController()?.frontViewPosition.rawValue)")
            self.revealViewController()?.revealToggle(self) //사이드바 닫아주기
            //print("self.revealViewController()?.frontViewPosition.rawValue : \(self.revealViewController()?.frontViewPosition.rawValue)")
        }
        self.view.endEditing(true)
    }

}
