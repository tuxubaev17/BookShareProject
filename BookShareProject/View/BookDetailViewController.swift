//
//  BookDetailViewController.swift
//  BookShareProject
//
//  Created by Alikhan Tuxubayev on 07.03.2021.
//

import UIKit

class BookDetailViewController: UIViewController {

    
    lazy var titleName: UILabel = {
        let title = UILabel()
        title.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        title.font = UIFont(name: "Roboto-Bold", size: 100)
        title.text = "Name"
        title.textAlignment = .center
        return title
}()
        
    lazy var bookImage: UIImageView = {
        let image = UIImageView()
        image.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        image.layer.shadowOpacity = 1
        image.layer.shadowRadius = 4
        image.layer.shadowOffset = CGSize(width: 0, height: 4)
        image.layer.cornerRadius = 7
        image.clipsToBounds = true
        image.image = UIImage(named: "")
        image.contentMode = .scaleAspectFill
        return image
}()
        
        lazy var authorName: UILabel = {
            let name = UILabel()
            name.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            name.font = UIFont(name: "Roboto-Medium", size: 12)
            name.attributedText = NSMutableAttributedString(string: "Author Name", attributes: [NSAttributedString.Key.kern: 0.24])
            name.textAlignment = .center
            return name
        }()
        
    //    lazy var publishDate: UILabel = {
    //        let label = UILabel()
    //        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    //        label.font = UIFont(name: "Roboto-Medium", size: 12)
    //        label.text = "Publish Date"
    //        label.textAlignment = .center
    //        return label
    //    }()
        
        lazy var reservButton: UIButton = {
            let button = UIButton()
            button.setTitle("Reserv", for: .normal)
            button.backgroundColor = .black
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 3
            return button
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.view.backgroundColor = .white
            setupViews()
            
        }
        
        private func setupViews(){
            [titleName, authorName,bookImage, reservButton].forEach{
                self.view.addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
            
            
            titleName.widthAnchor.constraint(equalToConstant: 300).isActive = true
            titleName.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            titleName.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
            
            bookImage.topAnchor.constraint(equalTo: titleName.bottomAnchor, constant: 10).isActive = true
            bookImage.widthAnchor.constraint(equalToConstant: 190).isActive = true
            bookImage.heightAnchor.constraint(equalToConstant: 190).isActive = true
            bookImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            
            authorName.widthAnchor.constraint(equalToConstant: 200).isActive = true
            authorName.heightAnchor.constraint(equalToConstant: 20).isActive = true
            authorName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 83).isActive = true
            authorName.topAnchor.constraint(equalTo: bookImage.bottomAnchor, constant: 14).isActive = true
            authorName.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

                
            reservButton.widthAnchor.constraint(equalToConstant: 61).isActive = true
            reservButton.heightAnchor.constraint(equalToConstant: 18).isActive = true
            reservButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            reservButton.topAnchor.constraint(equalTo: authorName.bottomAnchor, constant: 20).isActive = true

            
        }


}
