//
//  SignInViewController.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/09.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit

import Alamofire
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser
import SwiftyJSON
import FBSDKLoginKit

class SignInViewController: BaseViewController {
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var pw: UITextField!
    @IBOutlet weak var viewAppleID: UIView!
    @IBOutlet weak var viewFacebookID: UIView!
    
    
    @IBAction func didClick(_ sender: UIBarButtonItem) {
        super.dismissKeyboard()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            addAppleIDButton()
        }
        
        // facebook button
        let loginButton = FBLoginButton()
        loginButton.frame = viewFacebookID.bounds
        viewFacebookID.addSubview(loginButton)
        
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        //
        //            UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavigation")
        //        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
    
    
    @objc func keyboardWillShow(_ sender: Notification) {
        
        guard let keyboardFrame = sender.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        scrollView.contentInset.bottom = 0
    }
    
    @available(iOS 13.0, *)
    func addAppleIDButton() {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .whiteOutline)
        button.addTarget(self, action: #selector(handleAppleSignInButton), for: .touchUpInside)
        
        viewAppleID.isHidden = false
        button.frame = viewAppleID.bounds
        viewAppleID.addSubview(button)
    }
    
    @IBAction func handleKakaoSignInButton() {
        
        // 카카오톡 설치 여부 확인
        if (AuthApi.isKakaoTalkLoginAvailable()) {
            AuthApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    
                    //do something
                    if let auth = oauthToken {
                        print("카카오 앱 로그인: \(auth)")
                        
                        var snsData = [String: Any]()
                        snsData.updateValue("카카오톡", forKey: "snsType")
                        snsData.updateValue(auth.accessToken, forKey: "user_email")
                        snsData.updateValue(auth.accessToken, forKey: "user_pw")
                        snsData.updateValue(1, forKey: "group_id")
                        snsData.updateValue("", forKey: "user_phone")
                        self.actionLogin(snsData: snsData)
                    }
                }
            }
        } else {
            Common.GF_TOAST(self.view, "카카오톡이 안깔려있음")
            // 카카오계정으로 로그인
            AuthApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoAccount() success.")
                    
                    //do something
                    if let auth = oauthToken {
                        print("카카오 웹 로그인: \(auth)")
                        
                        var snsData = [String: Any]()
                        snsData.updateValue("카카오톡", forKey: "snsType")
                        snsData.updateValue(auth.accessToken, forKey: "user_email")
                        snsData.updateValue(auth.accessToken, forKey: "user_pw")
                        snsData.updateValue(1, forKey: "group_id")
                        snsData.updateValue("", forKey: "user_phone")
                        self.actionLogin(snsData: snsData)
                    }
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    @objc func handleAppleSignInButton() {
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    @IBAction func actionLogin(snsData: Dictionary<String,Any>? = nil) {
        
        var id: String = ""
        var pw: String = ""
        
        if let snsData = snsData {
            id = snsData["user_email"] as? String ?? ""
            pw = snsData["user_pw"] as? String ?? ""
            
            ///TODO:  비밀번호에 특수문자 넣으면 오류나서 일단 여기서 테스트
            self.askRegister(snsData: snsData)
            
            return
        } else {
            
            // 일반 가입만 검증
            id = self.id.text ?? ""
            pw = self.pw.text ?? ""
            
            if !Common.GF_ISVALID_EMAIL(id) {
                Common.GF_TOAST(self.view, "이메일이 유효하지 않습니다.")
                return
            }
            
            if !Common.GF_IS_REGEX_PASS(pw) {
                Common.GF_TOAST(self.view, "비밀번호가 유효하지 않습니다.")
                return
            }
        }
        
        // id, pw 검증
        if id.count > 0 && pw.count > 0 {
            
            let url = "http://zanghscoding.iptime.org:3000/api/login"
            //let url = "http://dev.app.hoduware.com/api/v1/auth/login/0"
            var params = Dictionary<String,Any>()
            params.updateValue(id, forKey: "user_email")
            params.updateValue(pw, forKey: "user_pw")
            //params.updateValue("test1@naver.com", forKey: "user_email")
            //params.updateValue("1111", forKey: "user_pw")
        
            super.showIndicator()
            
            AF.request(url, method: .post, parameters: params)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                
                super.hiddenIndicator()
                
                print(response)
                
                switch response.result {
                case .success(let result):
                    print("result: \(result)")

                    let result = JSON(result)
                    
                    // 일반가입 && resultCode 0 이면 회원가입 이력없어 오류처리
                    if result["resultCode"].intValue == 0 {
                        if snsData == nil  {
                            super.showServerUserException(msg: result["resultMsg"].stringValue)
                            return
                        } else if let snsData = snsData {
                            // sns 신규 가입 처리
                            self.askRegister(snsData: snsData)
                            

                            //UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavigation")
                            
                            return
                        }
                    }
                    //UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavigation")
                    
                    // 로그인 성공 -> 메인화면 이동
                    super.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SWRevealViewController"), animated: true, completion: nil)
                    
                case .failure(let error):
                    print("ERROR: \(error.localizedDescription)")
                    
                    Common.GF_TOAST(self.view, error.localizedDescription)
                }
            }
        } else {
            print("오류")
            super.showServerUserException(msg: "ID or PW invalid")
        }
    }
    
    @IBAction func actionJoin(_ sender: UIButton) {
        
        guard let targetVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpNavigation") else {
            fatalError()
        }
        super.present(targetVC, animated: true)
    }
    
    func askRegister(snsData: Dictionary<String,Any>) {

        // 가입 이력이 없으니 확인 받고 가입 유도
        let alert = UIAlertController.init(title: "\(snsData["snsType"] as? String ?? "")으로 가입한 이력이 없습니다.", message: "신규가입 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in

            guard let targetVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpNavigation") else {
                fatalError()
            }
            
            if let vc = targetVC.children.first as? SignUpViewController {
                vc.actionRegister(snsData: snsData)
            }
            super.present(targetVC, animated: true)
            
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension SignInViewController: UITextFieldDelegate {
    
    // Protocol - UITextFieldDelegate 텍스트필드 가릴때
    func textFieldDidEndEditing(_ textField: UITextField) {
        super.dismissKeyboard()
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
}

extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        Common.GF_TOAST(self.view, "Apple ID 로그인 실패\n\(error.localizedDescription)")
        print("didCompleteWithError: \(error)")
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let user = credential.user
            let email = credential.email
            
            print("""
                user: \(user)
                email: \(email ?? "email is not provided")
                """)
            //print("user: \(user)\nemail: \(email)")
            
            if let fullName = credential.fullName {
                print("full name: \(fullName.givenName ?? "") \(fullName.middleName ?? "") \(fullName.familyName ?? "")")
            }
            

            var snsData = [String: Any]()
            snsData.updateValue("Apple ID", forKey: "snsType")
            snsData.updateValue(user, forKey: "user_email")
            snsData.updateValue(user, forKey: "user_pw")
            snsData.updateValue(1, forKey: "group_id")
            snsData.updateValue("", forKey: "user_phone")
            self.actionLogin(snsData: snsData)
        }
        
    }
}
