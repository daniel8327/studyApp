//
//  SignInViewController.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/09.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit

import Alamofire

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var pw: UITextField!
    
    @IBAction func didClick(_ sender: UIBarButtonItem) {
        dismissKeyboard()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        //
        //            UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavigation")
        //        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func actionLogin() {
        if !Common.GF_ISVALID_EMAIL(id.text) {
            Common.GF_TOAST(self.view, "이메일이 유효하지 않습니다.")
            return
        }
//        if !Common.GF_IS_REGEX_PASS(pw.text) {
//            Common.GF_TOAST(self.view, "비밀번호가 유효하지 않습니다.")
//            return
//        }
        
        // id, pw 검증
        if id.text?.count ?? 0 > 0 && pw.text?.count ?? 0 > 0 {
            
            let url = "http://zanghscoding.iptime.org:3000/api/login"
            var params :[String:String] = [:]
            params.updateValue(id.text!, forKey: "id")
            params.updateValue(pw.text!, forKey: "pw")
            
            AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
                //.validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseJSON(completionHandler: { response in
                    
                    print(response)
                    
                    switch response.result {
                    case .success(let result):
                        print("result: \(result)")
                        
                        //UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavigation")
                        
                        self.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SWRevealViewController"), animated: true, completion: nil)
                        
                    case .failure(let error):
                        print("ERROR: \(error.localizedDescription)")
                        
                        Common.GF_TOAST(self.view, error.localizedDescription)
                    }
                    
                })
        } else {
            print("오류")
            Common.GF_TOAST(self.view, "ID or PW invalid")
        }
    }
    @IBAction func actionJoin(_ sender: UIButton) {
        
        guard let targetVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpNavigation") else {
            fatalError()
        }
        present(targetVC, animated: true)
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //화면 여백 터치 시 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    
    // Protocol - UITextFieldDelegate 텍스트필드 가릴때
    func textFieldDidEndEditing(_ textField: UITextField) {
        dismissKeyboard()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = toolbar
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == pw {
            actionLogin()
            textField.resignFirstResponder()
        } else if textField == id {
            pw.becomeFirstResponder()
        }
        
        return true
    }
    // 키보드 닫기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        
        guard let keyboardFrame = sender.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        scrollView.contentInset.bottom = 0
    }
    
    override open func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        
        if #available(iOS 13.0, *) {
            viewControllerToPresent.modalPresentationStyle = .fullScreen
        }
        
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
