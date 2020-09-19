//
//  IntroViewController.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/09.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {
    
    typealias SkipCallback = () -> Void
    var callback: SkipCallback?
    
    private var imageView: UIImageView?
    let index: Int
    private var button: UIButton?
    
    init(index: Int) {
        self.index = index
        
        imageView = UIImageView()
        button = UIButton()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView?.frame = self.view.frame
        
        button?.frame = CGRect(x: 20, y: self.view.bounds.maxY - 200, width: self.view.frame.width - 40, height: 50)
        button?.backgroundColor = UIColor.init(named: "backgroundColor")
        button?.layer.cornerRadius = 8
        
        self.view.addSubview(imageView!)
        self.view.addSubview(button!)
    }
    
    func setImageView(index: Int) {
        imageView?.image = UIImage(named: "image\(index).jpg")
        button?.setTitle((index == introScreenSize - 1 ? "닫기" : "Skip"), for: .normal)
        button?.setTitleColor(UIColor.init(named: "textColor"), for: .normal)
        
        button?.addTarget(self, action: #selector(closeIntroService), for: .touchUpInside)
    }
    
    @objc func closeIntroService() {
        UserDefaults.standard.set(true, forKey: "INTRO")
        if let callback = self.callback { callback() }
    }
}
