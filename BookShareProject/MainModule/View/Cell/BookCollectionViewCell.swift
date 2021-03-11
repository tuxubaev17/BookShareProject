//
//  BookCollectionViewCell.swift
//  BookShareProject
//
//  Created by Alikhan Tuxubayev on 09.03.2021.
//

import UIKit

class BookCollectionViewCell: UICollectionViewCell {
    
    lazy var iconImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 4
        image.layer.masksToBounds = true
        return image
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemPink
        return label
    }()
    
    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemPink
        return label
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        [titleLabel, authorLabel, iconImageView].forEach{
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        iconImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 7).isActive = true
        iconImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -7).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 7).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -7).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        authorLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 7).isActive = true
        authorLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -7).isActive = true
        authorLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        

    }
    
}
