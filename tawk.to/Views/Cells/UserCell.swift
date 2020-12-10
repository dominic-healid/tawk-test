//
//  UserCell.swift
//  tawk.to
//
//  Created by Dominic Valencia on 12/3/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    private lazy var userName: UILabel = {
        let label = UILabel()
        label.text = ""
        contentView.addSubview(label)
        return label
    }()
    
    private lazy var details: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        contentView.addSubview(label)
        return label
    }()
    
    private lazy var pictureView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        return imageView
    }()
    
    private lazy var noteImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "note")
        imageView.tintColor = .red
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        contentView.addSubview(imageView)
        return imageView
    }()

    var userProtocol: UserProtocol?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ user: User, _ indexPath: IndexPath, _ serialQueue: DispatchQueue) {
        
        if let u = userProtocol?.getUser(id: user.id) {
            self.userName.text = u.login
            self.details.text = u.url
            self.contentView.backgroundColor = u.seen ? .lightGray : UIColor(named: "tawkWhite")
            self.noteImage.isHidden = u.notes.isEmpty
        }
        
        serialQueue.async {
            self.pictureView.processLink(user.avatar_url, indexPath.row % 4 != 3)
        }
    }
    
    private func setupLayout() {
        pictureView.translatesAutoresizingMaskIntoConstraints = false
        pictureView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        pictureView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        pictureView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        pictureView.widthAnchor.constraint(equalTo: pictureView.heightAnchor).isActive = true
        
        userName.translatesAutoresizingMaskIntoConstraints = false
        userName.leadingAnchor.constraint(equalTo: pictureView.trailingAnchor, constant: 15).isActive = true
        userName.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10).isActive = true
        

        details.translatesAutoresizingMaskIntoConstraints = false
        details.leadingAnchor.constraint(equalTo: pictureView.trailingAnchor, constant: 15).isActive = true
        details.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 15).isActive = true
        details.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 0).isActive = true
        
        noteImage.translatesAutoresizingMaskIntoConstraints = false
        noteImage.widthAnchor.constraint(equalToConstant: 20).isActive = true
        noteImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
        noteImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        noteImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
    }
}
