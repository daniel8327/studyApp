//
//  IntroPageViewController.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/08.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit

class IntroPageViewController: UIPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        
        if UserDefaults.standard.bool(forKey: "INTRO") {
            
            // 다음 화면으로
            print("다음화면으로")
            goMain()
        } else {
            print("인트로 진행")
        }
        
        self.setViewControllers([getViewController(index: 0)] as [UIViewController], direction: .forward, animated: true) { _ in
            //self.setupPageControl()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for view in view.subviews {
            if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }
    
    private func getViewController(index: Int) -> UIViewController {
        
        let viewController = IntroViewController(index: index)
        viewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        viewController.setImageView(index: index)
        
        viewController.callback = { () -> Void in self.goMain() }
        
        return viewController
    }
    
    func goMain() {

        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Sign", bundle: nil).instantiateViewController(withIdentifier: "SignNavigation")
    }
    
    /*private func setupPageControl() {
        let appearance = UIPageControl.appearance()

        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.white
        appearance.backgroundColor = .clear
    }*/

}
extension IntroPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard var index = (viewController as? IntroViewController)?.index else {
            return nil
        }
        
        if index == 0 || index == NSNotFound { return nil }
        
        index -= 1
        return getViewController(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard var index = (viewController as? IntroViewController)?.index else {
            return nil
        }
        
        if index == NSNotFound { return nil }
        
        index += 1
        
        if index == introScreenSize { return nil }
        
        return getViewController(index: index)
    }
    
    /// presentationCount, presentationIndex 를 구현하면 setupPageControl 을 할 필요가 없다.
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return introScreenSize
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
