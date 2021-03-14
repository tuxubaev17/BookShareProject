//
//  TabBarController.swift
//  BookShareProject
//
//  Created by Alikhan Tuxubayev on 08.03.2021.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate{
    
    let mainPage = MainViewController()
    let searchPage = SearchViewController()
    let favPage = FavoritesViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        tabBar.clipsToBounds = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        let tabOneBarItem = UITabBarItem(title: "Books", image: UIImage(named: "books-stack-of-three"), selectedImage: UIImage(named: "books-active"))
        tabOneBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        mainPage.tabBarItem = tabOneBarItem
        
        let tabTwoBarItem = UITabBarItem(title: "Search", image: UIImage(named: "magnifying-glass"), selectedImage: UIImage(named: "magnifying-glass-2"))
        tabTwoBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        searchPage.tabBarItem = tabTwoBarItem
        
        let tabThirdBarItem = UITabBarItem(title: "Favorites", image: UIImage(named: "heartIcon"), selectedImage: UIImage(named: "heartIcon"))
        tabThirdBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        favPage.tabBarItem = tabThirdBarItem

        self.viewControllers = [mainPage, searchPage, favPage]

        
        }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
                print("Selected \(viewController.title!)")
            }
    }
    

 


