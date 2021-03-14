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
    let bookDetailVC = BookDetailViewController()
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

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Newly added"
        label.textColor = .white
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    
    lazy var allBooksTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "All books"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    lazy var firstBooksCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 260)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        let myCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        myCollectionView.register(BookCollectionViewCell.self, forCellWithReuseIdentifier: "cellA")
        myCollectionView.dataSource = self
        myCollectionView.delegate = self
        myCollectionView.backgroundColor = .white
        myCollectionView.isScrollEnabled = false
        return myCollectionView
    }()
           
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemPink
        self.title = "Books"
//        vc.delegate = self
//        self.present(vc, animated: true)
        setupViews()
        fetchData()
}
    
   private func fetchData(){
        bookViewModel.getAllBooks{ data in
            self.books = data
            DispatchQueue.main.async {
                self.firstBooksCollectionView.reloadData()
                self.booksTableView.reloadData()
            }
        }
    }
    
    private func setupViews(){
        [booksTableView, titleLabel, firstBooksCollectionView, allBooksTitleLabel].forEach{
            self.view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        firstBooksCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        firstBooksCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        firstBooksCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        firstBooksCollectionView.heightAnchor.constraint(equalToConstant: 230).isActive = true
        
        allBooksTitleLabel.topAnchor.constraint(equalTo: firstBooksCollectionView.bottomAnchor, constant: 20).isActive = true
        allBooksTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        booksTableView.topAnchor.constraint(equalTo: allBooksTitleLabel.bottomAnchor, constant: 10).isActive = true
        booksTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        booksTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        booksTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: "cellA", for: indexPath) as? BookCollectionViewCell
        cellA?.titleLabel.text = books[indexPath.row].title
        cellA?.authorLabel.text = books[indexPath.row].author
        bookViewModel.setBookImage(imagePath: books[indexPath.row].image ?? "null", bookIV: cellA!.iconImageView)
        return cellA!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        bookDetailVC.titleName.text = books[indexPath.row].title
        bookDetailVC.authorName.text = books[indexPath.row].author
        bookViewModel.setBookImage(imagePath: books[indexPath.row].image ?? "null", bookIV: bookDetailVC.bookImage)
        self.navigationController?.pushViewController(bookDetailVC, animated: true)
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
        bookViewModel.setBookImage(imagePath: books[indexPath.row].image ?? "null", bookIV: cell!.iconImageView)
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bookDetailVC.favBook = books[indexPath.row]
        
        bookDetailVC.titleName.text = books[indexPath.row].title
        bookDetailVC.authorName.text = books[indexPath.row].author
        bookViewModel.setBookImage(imagePath: books[indexPath.row].image ?? "null", bookIV: bookDetailVC.bookImage)
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
