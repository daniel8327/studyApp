//
//  ViewController.swift
//  StudyApp
//
//  Created by 장태현 on 2020/09/07.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        let screenSize  = UIScreen.main.bounds.size
        let cellWidth   = floor(screenSize.width * 0.8)
        let cellHeight  = floor(collectionView.frame.height)
        let insetX      = (view.bounds.width - cellWidth) / 2.0
        let insetY      = (view.bounds.height - cellHeight) / 2.0
        
        //print("screenSize : \(screenSize  )")
        //print("cellWidth : \(cellWidth   )")
        //print("cellHeight : \(cellHeight  )")
        //print("insetX : \(insetX      )")
        //print("insetY : \(insetY      )")
        
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing      = 20
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .random
        return cell
    }
}

extension UIColor {
    class var random: UIColor {
        return UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1.0)
    }
}
