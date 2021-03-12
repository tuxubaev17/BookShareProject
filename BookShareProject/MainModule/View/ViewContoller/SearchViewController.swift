//
//  SearchViewController.swift
//  BookShareProject
//
//  Created by Alikhan Tuxubayev on 12.03.2021.
//

import UIKit
import Moya

class SearchViewController: UIViewController {

    var books = [Books]()
    
    let bookViewModel = BookViewModel()
    let bookDetailVC = BookDetailViewController()
    let bookProvider = MoyaProvider<BookService>()
    
    lazy var searchBar: UISearchBar = {
      let search = UISearchBar()
      search.autocapitalizationType = .none
      search.placeholder = " Title name "
      return search
      }()
      
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
        self.view.backgroundColor = .white
        setUpViews()
        searchBar.delegate = self
        bookViewModel.getAllBooks { data in
           self.books = data
           DispatchQueue.main.async {
               self.tableView.reloadData()
           }
    }
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                self.view.addGestureRecognizer(tap)
        
}
    
    @objc func handleTap() {
            searchBar.resignFirstResponder()
        }
    
    private func setUpViews() {
         [searchBar, tableView].forEach {
             self.view.addSubview($0)
             $0.translatesAutoresizingMaskIntoConstraints = false
         }
         
         searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
         searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
         searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
         searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
         
         tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
         tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
         tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
         tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
     }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookVC", for: indexPath) as? BookTableViewCell
        bookViewModel.setBookImage(imagePath: books[indexPath.row].image ?? "nil", bookIV: cell!.iconImageView)
        cell?.titleLabel.text = books[indexPath.row].title
        cell?.authorLabel.text = books[indexPath.row].author
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bookDetailVC.titleName.text = books[indexPath.row].title
        bookDetailVC.authorName.text = books[indexPath.row].author
        bookViewModel.setBookImage(imagePath: books[indexPath.row].image ?? "null", bookIV: bookDetailVC.bookImage)
        self.navigationController?.pushViewController(bookDetailVC, animated: true)
     }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            bookViewModel.getAllBooks { data in
               self.books = data
               
               DispatchQueue.main.async {
                   self.tableView.reloadData()
               }
        }
        } else {
            if searchBar.selectedScopeButtonIndex == 0 {
                books = books.filter({ (book) -> (Bool) in
                    return (book.title!.lowercased().contains(searchText.lowercased()))
                })
            }else {
                books = books.filter({ (book)-> Bool in
                    return (book.author!.contains(searchText))
                })
            }
        }
        self.tableView.reloadData()
 }
    
}
