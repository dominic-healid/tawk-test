//
//  ProfileViewController.swift
//  tawk.to
//
//  Created by Dominic Valencia on 12/5/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

class ProfileViewController: UIViewController {

    private lazy var scrollView: TPKeyboardAvoidingScrollView = {
        let scrollView = TPKeyboardAvoidingScrollView()
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatarView, followersStackView, userDetailsView, notesView, buttonView])
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.backgroundColor = .blue
        self.scrollView.addSubview(stackView)
        return stackView
    }()
    
    private lazy var avatarView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "note")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        avatarView.addSubview(imageView)
        return imageView
    }()
    
    private lazy var followersStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        self.scrollView.addSubview(stackView)
        return stackView
    }()
    
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.text = "followers"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.text = "following"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var userDetailsView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var userDetails: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 5
        
        userDetailsView.addSubview(view)
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name:"
        
        userDetailsView.addSubview(label)
        return label
    }()
    
    private lazy var name: UILabel = {
        let label = UILabel()
        label.text = "Name"
        
        userDetailsView.addSubview(label)
        return label
    }()
    
    private lazy var companyLabel: UILabel = {
        let label = UILabel()
        label.text = "Company:"
        
        userDetailsView.addSubview(label)
        return label
    }()
    
    private lazy var company: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.numberOfLines = 0
        userDetailsView.addSubview(label)
        return label
    }()
    
    private lazy var blogLabel: UILabel = {
        let label = UILabel()
        label.text = "Blog:"
        
        userDetailsView.addSubview(label)
        return label
    }()
    
    private lazy var blog: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.numberOfLines = 0
        userDetailsView.addSubview(label)
        return label
    }()
    
    private lazy var notesView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var notesLabel: UILabel = {
        let label = UILabel()
        label.text = "Notes"
        
        notesView.addSubview(label)
        return label
    }()
    
    private lazy var notesTextView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 10
        
        notesView.addSubview(textView)
        return textView
    }()
    
    private lazy var buttonView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.addTarget(self, action: #selector(self.saveUser), for: .touchUpInside)
        buttonView.addSubview(button)
        return button
    }()
    
    var viewModel: ProfileViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(scrollView)
        self.view.backgroundColor = .white
        setupLayout()
        handleViewModelResult()
        self.viewModel?.fetchUserDetails()
    }
    
    func handleViewModelResult() {
        self.viewModel?.changeResult = { type in
            switch type {
            case .loadUserDetails:
                DispatchQueue.main.async {
                    self.avatarImageView.processLink(self.viewModel?.user?.avatar_url)
                    self.followersLabel.attributedText = self.viewModel?.userFollowers()
                    self.followingLabel.attributedText = self.viewModel?.userFollowing()
                    self.name.text = self.viewModel?.user?.login
                    self.company.text = self.viewModel?.userDetails?.company
                    self.blog.text = self.viewModel?.userDetails?.blog
                    self.notesTextView.text = self.viewModel?.getNotes()
                }
            case .savedNotes:
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc
    func saveUser() {
        self.viewModel?.saveUser(notes: notesTextView.text)
    }
    
    func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1, constant: 0).isActive = true
        
        avatarView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        avatarImageView.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor, constant: 0).isActive = true
        avatarImageView.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor, constant: 0).isActive = true
        
        userDetailsView.translatesAutoresizingMaskIntoConstraints = false
        userDetailsView.bottomAnchor.constraint(equalTo: userDetails.bottomAnchor, constant: 15).isActive = true
        
        userDetails.translatesAutoresizingMaskIntoConstraints = false
        userDetails.leadingAnchor.constraint(equalTo: userDetailsView.leadingAnchor, constant: 20).isActive = true
        userDetails.topAnchor.constraint(equalTo: userDetailsView.topAnchor, constant: 10).isActive = true
        userDetails.bottomAnchor.constraint(equalTo: blog.bottomAnchor, constant: 10).isActive = true
        userDetails.trailingAnchor.constraint(equalTo: userDetailsView.trailingAnchor, constant: -20).isActive = true
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: userDetails.leadingAnchor, constant: 15).isActive = true
        nameLabel.topAnchor.constraint(equalTo: userDetails.topAnchor, constant: 10).isActive = true
        
        name.translatesAutoresizingMaskIntoConstraints = false
        name.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 15).isActive = true
        name.topAnchor.constraint(equalTo: userDetails.topAnchor, constant: 10).isActive = true
        
        companyLabel.translatesAutoresizingMaskIntoConstraints = false
        companyLabel.leadingAnchor.constraint(equalTo: userDetails.leadingAnchor, constant: 15).isActive = true
        companyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10).isActive = true
        
        company.translatesAutoresizingMaskIntoConstraints = false
        company.leadingAnchor.constraint(equalTo: companyLabel.trailingAnchor, constant: 15).isActive = true
        company.trailingAnchor.constraint(equalTo: userDetails.trailingAnchor, constant: 0).isActive = true
        company.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 10).isActive = true
        
        blogLabel.translatesAutoresizingMaskIntoConstraints = false
        blogLabel.leadingAnchor.constraint(equalTo: userDetails.leadingAnchor, constant: 15).isActive = true
        blogLabel.topAnchor.constraint(equalTo: company.bottomAnchor, constant: 20).isActive = true
        
        blog.translatesAutoresizingMaskIntoConstraints = false
        blog.leadingAnchor.constraint(equalTo: blogLabel.trailingAnchor, constant: 15).isActive = true
        blog.trailingAnchor.constraint(equalTo: userDetails.trailingAnchor, constant: 0).isActive = true
        blog.topAnchor.constraint(equalTo: company.bottomAnchor, constant: 20).isActive = true
        
        notesView.translatesAutoresizingMaskIntoConstraints = false
        notesView.bottomAnchor.constraint(equalTo: notesTextView.bottomAnchor, constant: 15).isActive = true
        
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        notesLabel.leadingAnchor.constraint(equalTo: notesView.leadingAnchor, constant: 15).isActive = true
        notesLabel.topAnchor.constraint(equalTo: notesView.topAnchor, constant: 10).isActive = true
        
        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        notesTextView.leadingAnchor.constraint(equalTo: notesView.leadingAnchor, constant: 15).isActive = true
        notesTextView.topAnchor.constraint(equalTo: notesLabel.bottomAnchor, constant: 10).isActive = true
        notesTextView.trailingAnchor.constraint(equalTo: notesView.trailingAnchor, constant: -15).isActive = true
        notesTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 15).isActive = true
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 15).isActive = true
        saveButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 0).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -15).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

}
