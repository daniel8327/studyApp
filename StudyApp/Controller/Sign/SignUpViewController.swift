//
//  SingUpViewController.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/12.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit

import M13Checkbox
import Alamofire
import SwiftyJSON

class SignUpViewController: BaseViewController {
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var checkBoxView: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord1: UITextField!
    @IBOutlet weak var passWord2: UITextField!
    @IBOutlet weak var cellNo: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let checkbox = M13Checkbox()
        checkbox.frame = checkBoxView.bounds
        checkBoxView.addSubview(checkbox)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func didClick(_ sender: UIBarButtonItem) {
        dismissKeyboard()
    }
    
    @IBAction func actionCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func actionRegister() {
            
        let url = "http://zanghscoding.iptime.org:3000/api/signup"

        var params = Dictionary<String,Any>()
        params.updateValue(email.text!, forKey: "user_email")
        params.updateValue(passWord1.text!, forKey: "user_pw")
        params.updateValue(userName.text!, forKey: "user_nm")
        params.updateValue(segment.selectedSegmentIndex, forKey: "group_id")
        params.updateValue(cellNo.text!, forKey: "user_phone")
        //params.updateValue("test1@naver.com", forKey: "user_email")
        //params.updateValue("1111", forKey: "user_pw")
    
        super.showIndicator()
        
        AF.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON
            { response in
            
            super.hiddenIndicator()
            
            //            AF.request(url, method: .post, parameters: params)
            //                //.validate(statusCode: 200..<300)
            //                //.validate(contentType: ["application/json"])
            //                .responseJSON { response in
            
            print(response)
            
            switch response.result {
            case .success(let result):
                print("result: \(result)")
                
                let result = JSON(result)
                print("result2: \(result)")
                if result["resultCode"].intValue == 0 {
                    super.showServerUserException(msg: result["resultMsg"].stringValue)
                    return
                }
                
                //UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavigation")

                guard let targetVC = self.storyboard?.instantiateViewController(withIdentifier: "SignNavigation") else {
                    fatalError()
                }
                super.present(targetVC, animated: true)
                
            case .failure(let error):
                print("ERROR: \(error.localizedDescription)")

                super.showServerUserException(msg: error.localizedDescription)
            }
        }
    }
    
    
    @objc func keyboardWillShow(_ sender: Notification) {
        
        guard let keyboardFrame = sender.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        scrollView.contentInset.bottom = 0
    }
}
extension SignUpViewController: UITextFieldDelegate {
    
    // Protocol - UITextFieldDelegate 텍스트필드 가릴때
    func textFieldDidEndEditing(_ textField: UITextField) {
        super.dismissKeyboard()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = toolbar
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == cellNo {
            actionRegister()
            textField.resignFirstResponder()
        } else if textField == email {
            userName.becomeFirstResponder()
        } else if textField == userName {
            passWord1.becomeFirstResponder()
        } else if textField == passWord1 {
            passWord2.becomeFirstResponder()
        } else if textField == passWord2 {
            cellNo.becomeFirstResponder()
        }
        
        return true
    }
}
