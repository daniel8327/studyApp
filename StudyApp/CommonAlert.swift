//
//  CommonAlert.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/12.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit

class CommonAlert {
    
    init(vc: UIViewController, title: String, message: String, style: UIAlertController.Style = .alert) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        
        vc.present(alert, animated: true, completion: nil)
    }
}
