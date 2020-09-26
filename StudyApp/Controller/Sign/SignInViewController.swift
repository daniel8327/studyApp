//
//  SignInViewController.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/09.
//  Copyright © 2020 장태현. All rights reserved.
//

import CoreData
import UIKit

import Alamofire
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser
import SwiftyJSON
import FBSDKCoreKit
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
        
        
        
                    //UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "SimpleMemoMain", bundle: nil).instantiateViewController(withIdentifier: "ListNav")
        
        
        
        // facebook button
        let loginButton = FBLoginButton()
        loginButton.frame = viewFacebookID.bounds
        viewFacebookID.addSubview(loginButton)
        //loginButton.permissions = ["public_profile", "emial", "user_friends"]
        //loginButton.addTarget(self, action: #selector(handleFacebookSignInButton), for: .touchUpInside)
        loginButton.delegate = self
        
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        //
        //            UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavigation")
        //        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 자동로그인 체크
        let loginHistory = CoreDataManager.shared.getLogin()
        if loginHistory.count > 0 {
            
            var snsData = [String: Any]()
            snsData.updateValue(loginHistory.first!.login_type, forKey: "login_type")
            snsData.updateValue(loginHistory.first!.user_email, forKey: "user_email")
            snsData.updateValue(loginHistory.first!.user_pw, forKey: "user_pw")
            snsData.updateValue(loginHistory.first!.group_id, forKey: "group_id")
            snsData.updateValue(loginHistory.first!.user_phone, forKey: "user_phone")
            self.actionLogin(snsData: snsData)
        }
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
        
        // 기정보 가져오기
        UserApi.shared.accessTokenInfo { accessToken, error in
            if let error = error {
                print("토큰 유효성 검사: \(error)")
                
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
                                self.getKakaoUserInfo()
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
                                self.getKakaoUserInfo()
                            }
                        }
                    }
                }
            } else {
                self.getKakaoUserInfo()
            }
        }
    }
    
    func getKakaoUserInfo() {
        UserApi.shared.me { user, error in
            if let error = error {
                Common.GF_TOAST(self.view, error.localizedDescription)
            } else {
                
                guard let user = user else { fatalError("카카오톡 유져정보 획득 실패") }
                print("user: \(user)")

                var snsData = [String: Any]()
                snsData.updateValue("카카오톡", forKey: "login_type")
                snsData.updateValue("\(user.id)", forKey: "user_email")
                snsData.updateValue("\(user.id)", forKey: "user_pw")
                snsData.updateValue(1, forKey: "group_id")
                snsData.updateValue("", forKey: "user_phone")
                self.actionLogin(snsData: snsData)
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
    
    @objc func handleFacebookSignInButton() {
        
        
    }
    
    @IBAction func actionLogin(snsData: Dictionary<String,Any>? = nil) {
        
        var id = ""
        var pw = ""
        var loginType = ""
        var groupId :Int16 = 0
        var userPhone = ""
        
        if let snsData = snsData {
            id = snsData["user_email"] as? String ?? ""
            pw = snsData["user_pw"] as? String ?? ""
            loginType = snsData["login_type"] as? String ?? ""
            groupId = snsData["group_id"] as? Int16 ?? 0
            userPhone = snsData["user_phone"] as? String ?? ""
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
            loginType = "일반가입"
            groupId = 0
            userPhone = "01064553339"
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
                    
                    CoreDataManager.shared.saveLogin(userEmail: id, userPw: pw, loginType: loginType, groupId: groupId, userPhone: userPhone) { isDone in
                        print("coreData write => \(isDone)")
                    }
                    
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
        let alert = UIAlertController.init(title: "\(snsData["login_type"] as? String ?? "")으로 가입한 이력이 없습니다.", message: "신규가입 하시겠습니까?", preferredStyle: .alert)
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
            snsData.updateValue("Apple ID", forKey: "login_type")
            snsData.updateValue(user, forKey: "user_email")
            snsData.updateValue(user, forKey: "user_pw")
            snsData.updateValue(1, forKey: "group_id")
            snsData.updateValue("", forKey: "user_phone")
            self.actionLogin(snsData: snsData)
        }
        
    }
}
extension SignInViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        guard let token = result?.token?.tokenString else {
            fatalError("페이스북 토큰값 얻기 실패")
        }

        print("페북 앱 로그인: \(token)")
        
        var snsData = [String: Any]()
        snsData.updateValue("페이스북", forKey: "login_type")
        snsData.updateValue(token, forKey: "user_email")
        snsData.updateValue(token, forKey: "user_pw")
        snsData.updateValue(1, forKey: "group_id")
        snsData.updateValue("", forKey: "user_phone")
        self.actionLogin(snsData: snsData)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("facebook log out")
    }
}
