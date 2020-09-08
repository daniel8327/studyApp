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
        
        self.setViewControllers([getViewController(index: 0)] as [UIViewController], direction: .forward, animated: true) { _ in
            //self.setupPageControl()
        }
        
    }
    
    private func getViewController(index: Int) -> UIViewController {
        
        let viewController = IntroViewController(index: index)
        viewController.setImageView(index: index)
        return viewController
    }
//    private func setupPageControl() {
//        let appearance = UIPageControl.appearance()
//
//        appearance.pageIndicatorTintColor = UIColor.gray
//        appearance.currentPageIndicatorTintColor = UIColor.white
//        appearance.backgroundColor = .clear
//    }

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
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return introScreenSize
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
