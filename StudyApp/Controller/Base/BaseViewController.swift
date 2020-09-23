//
//  BaseViewController.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/23.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit

import ANActivityIndicator

class BaseViewController: UIViewController {

    lazy var indicator = ANActivityIndicatorView(frame: self.view.frame, animationType: .ballClipRotatePulse, color: .darkGray, padding: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(indicator)
        // Do any additional setup after loading the view.
    }
    
    //화면 여백 터치 시 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    
    override open func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        
        if #available(iOS 13.0, *) {
            viewControllerToPresent.modalPresentationStyle = .fullScreen
        }
        
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    func showServerUserException(msg: String) {

        Common.GF_TOAST(self.view, msg)
    }
    
    // 키보드 닫기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showIndicator() {
        
        if !indicator.isAnimating {
            indicator.startAnimating()
        }
    }
    
    func hiddenIndicator() {

        if indicator.isAnimating {
            indicator.stopAnimating()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
