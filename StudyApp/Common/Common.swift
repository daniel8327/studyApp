//
//  Common.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/12.
//  Copyright © 2020 장태현. All rights reserved.
//

import Foundation

import Toast_Swift

class Common {
    //----------------------------------------------------------------------------------------------------------
    // Email 정규식 체크
    //----------------------------------------------------------------------------------------------------------
    class func GF_ISVALID_EMAIL(_ email:String?) -> Bool {
        // print("validate calendar: \(testStr)")
        guard let email = email else {
            return false
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let lo_emailRegEx = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return lo_emailRegEx.evaluate(with: email)
    }
    
    /// 비밀번호 정규식 체크 영문,숫자,특수문자 포함 8~12자
    /// - Parameter ps_pass: 비밀번호 문자열
    class func GF_IS_REGEX_PASS(_ ps_pass:String?) -> Bool {
        
        guard let pass = ps_pass else {
            return false
        }
        
        // 숫자 + 영문 + 특수문자 8자리
        //let ls_passRegEx = "((?=.*[a-zA-Z])(?=.*[0-9])(?=.*[\\{\\}\\[\\]\\/?.,;:|\\)*~`!^\\-_+<>@\\#$%&\\\\\\=\\(\\'\\\"]).{8,})"
        // 숫자 + 영문 8자리
        let ls_passRegEx = "((?=.*[a-zA-Z])(?=.*[0-9]).{8,})"
        
        let lo_passRegEx = NSPredicate(format:"SELF MATCHES %@", ls_passRegEx)
        return lo_passRegEx.evaluate(with: pass)
    }
    
    //----------------------------------------------------------------------------------------------------------
    // 최상위 화면에 토스트를 띄운다.
    // param : po_view          - 현재뷰
    // param : ps_tilte         - 토스트 내용
    // param : po_interval      - 토스트 띄울 시간 - Default 2
    // param : ps_position      - 토스트 띄울 위치 - Default CSToastPositionCenter
    // param : pb_root          - 토스트 띄울시 최상위 뷰에 띄워야 하는지 여부 false 이면 self.view에 뿌려짐
    //----------------------------------------------------------------------------------------------------------
    class func GF_TOAST(_ po_view:UIView?, _ ps_title:String, _ pb_root:Bool=true){
        
        GF_TOAST(po_view, ps_title, 2, ToastPosition.center, pb_root)
    }

    class func GF_TOAST(_ po_view:UIView?, _ ps_title:String, _ po_interval:TimeInterval, _ pb_root:Bool=true){
        GF_TOAST(po_view, ps_title, po_interval, ToastPosition.center, pb_root)
    }

    class func GF_TOAST(_ po_view:UIView?, _ ps_title:String, _ ps_position:ToastPosition, _ pb_root:Bool=true){
        GF_TOAST(po_view, ps_title, 2, ps_position, pb_root)
    }

    class func GF_TOAST(_ po_view:UIView?, _ ps_title:String, _ po_interval:TimeInterval, _ po_position:ToastPosition, _ pb_root:Bool=true){
        
        guard po_view != nil else {return}
        
        var lo_superView :UIView = po_view!
        
        if pb_root {
            while lo_superView.superview != nil {
                lo_superView = lo_superView.superview!
            }
        }
        lo_superView.makeToast(ps_title, duration: po_interval, position: po_position)
    }
}
