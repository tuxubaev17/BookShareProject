//
//  FavoritesViewController.swift
//  BookShareProject
//
//  Created by Alikhan Tuxubayev on 14.03.2021.
//

import UIKit

class FavoritesViewController: UIViewController {

    let bookViewModel = BookViewModel()
    
    lazy var tableView: UITableView = {
       let tableView = UITableView()
       tableView.dataSource = self
       tableView.delegate = self
       tableView.backgroundColor = .gray
       tableView.register(BookTableViewCell.self, forCellReuseIdentifier: "BookVC")
       return tableView
       }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search"
        setUpViews()
      
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    private func setUpViews() {
      view.addSubview(tableView)
      tableView.translatesAutoresizingMaskIntoConstraints = false
      tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Favorites.roots.favBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookVC", for: indexPath) as? BookTableViewCell
        bookViewModel.setBookImage(imagePath: Favorites.roots.favBooks[indexPath.row].image ?? "nil", bookIV: cell!.iconImageView)
        cell?.titleLabel.text = Favorites.roots.favBooks[indexPath.row].title
        cell?.authorLabel.text = Favorites.roots.favBooks[indexPath.row].author
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
      }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = BookDetailViewController()
        detailVC.favBook = Favorites.roots.favBooks[indexPath.row]
        detailVC.authorName.text = Favorites.roots.favBooks[indexPath.row].author
        detailVC.titleName.text = Favorites.roots.favBooks[indexPath.row].title
        bookViewModel.setBookImage(imagePath: Favorites.roots.favBooks[indexPath.row].image ?? "nil", bookIV: detailVC.bookImage)
        detailVC.addToFavorite.setBackgroundImage(UIImage(named: "heart.filled"), for: .normal)
        self.navigationController?.pushViewController(detailVC, animated: true)
        }
    
}
