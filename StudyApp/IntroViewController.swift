//
//  IntroViewController.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/09.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {
    
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
        //(40 876; 374 20)
        //(40 696; 374 20)
        button?.frame = CGRect(x: 20, y: self.view.bounds.maxY - 200, width: self.view.frame.width - 40, height: 50)
        button?.backgroundColor = .clear
        
        self.view.addSubview(imageView!)
        self.view.addSubview(button!)
    }
    
    func setImageView(index: Int) {
        imageView?.image = UIImage(named: "image\(index).jpg")
        
        if index == introScreenSize - 1 { button?.setTitle("닫기", for: .normal) }
        else { button?.setTitle("다음", for: .normal)}
    }
}
