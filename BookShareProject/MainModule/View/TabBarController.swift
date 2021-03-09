//
//  TabBarController.swift
//  BookShareProject
//
//  Created by Alikhan Tuxubayev on 08.03.2021.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        tabBar.clipsToBounds = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let mainPage = MainViewController()
        let tabOneBarItem = UITabBarItem(title: "Tab 1", image: UIImage(named: "books-stack-of-three"), selectedImage: UIImage(named: "books-active"))
        tabOneBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        mainPage.tabBarItem = tabOneBarItem
        self.viewControllers = [mainPage]
        }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
                print("Selected \(viewController.title!)")
            }
    }
    

 


