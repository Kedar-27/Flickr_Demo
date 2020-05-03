//
//  FRMainTabBarController.swift
//  Flickr_Demo
//
//  Created by Kedar Sukerkar on 03/05/20.
//  Copyright © 2020 Kedar-27. All rights reserved.
//

import UIKit

class FRMainTabBarController: UITabBarController, UITabBarControllerDelegate {

        
    // MARK: - Outlets
    lazy var homeVC: FRHomeVC = {
        let vc = FRHomeVC()
        vc.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 0)
        return vc
    }()
    
    lazy var searchVC: FRSearchVC = {
        let vc = FRSearchVC()
        vc.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        return vc
    }()

    
    // MARK: - Properties
    var viewControllersList = [UIViewController]()

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
    }
    
    private func setupVC(){
        self.delegate = self
        self.viewControllersList =  [homeVC, searchVC]
        self.viewControllers = self.viewControllersList
    }
    
    private func setupUI(){
        
    }
    
    

    
    
    
}
