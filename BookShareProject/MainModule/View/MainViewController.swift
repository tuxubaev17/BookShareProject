//
//  ViewController.swift
//  BookShareProject
//
//  Created by Alikhan Tuxubayev on 07.03.2021.
//

import UIKit
import Moya
import Griffon_ios_spm



class MainViewController: UIViewController {

    var books = [Books]()
    let bookViewModel = BookViewModel()
    let bookProvider = MoyaProvider<BookService>()
    let griffon = GriffonConfigurations()
    let vc = SignInViewController()
    
    lazy var booksTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: "BookTableVC")
        return tableView
    }()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Books"
//        vc.delegate = self
//        self.present(vc, animated: true)
        setupViews()
        getAllBooks()
}
    private func setupViews(){
        [booksTableView].forEach{
            self.view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        booksTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        booksTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        booksTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        booksTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
    }
    
    private func getAllBooks(){
        bookProvider.request(.getAllBooks) { (result) in
            switch result {
            case .success(let response):
                let loadBooks = try! JSONDecoder().decode([Books].self, from: response.data)
                self.books = loadBooks
                self.booksTableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookTableVC", for: indexPath) as? BookTableViewCell
        cell?.titleLabel.text = books[indexPath.row].title
        cell?.authorLabel.text = books[indexPath.row].author
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let bookDetailVC = BookDetailViewController()
         bookDetailVC.titleName.text = books[indexPath.row].title
         bookDetailVC.authorName.text = books[indexPath.row].author
         bookDetailVC.setBookImage(imagePath: books[indexPath.row].image ?? "nil")
         self.navigationController?.pushViewController(bookDetailVC, animated: true)
     }
    
}

extension MainViewController:  SignInViewControllerDelegate {
    
    func successfullSignIn(_ ctrl: SignInViewController) {
        self.dismiss(animated: true, completion: {
            print(Griffon.shared.idToken ?? "null")
        })
    }
    
    func successfullSignUp(_ ctrl: SignInViewController) {
        self.dismiss(animated: true, completion: {
            print(Griffon.shared.idToken ?? "null")
        })
    }
    
    
}
