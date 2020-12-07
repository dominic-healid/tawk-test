//
//  UsersViewController.swift
//  tawk.to
//
//  Created by Dominic Valencia on 12/3/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import UIKit
import PagedLists
import Reachability

class UsersViewController: UIViewController {

    private let reachability = try! Reachability()
    
    private lazy var noInternetView: UILabel = {
        let label = UILabel()
        label.text = "No internet connection"
        label.frame = CGRect.zero
        label.textColor = .white
        label.backgroundColor = .red
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var tableView: PagedTableView = {
        let tableView = PagedTableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.updateDelegate = self
        tableView.elementsPerPage = 20
        return tableView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.delegate = self
        search.sizeToFit()
        search.showsCancelButton = true
        search.placeholder = "Search for user"
        return search
    }()
    
    private let dispatchGroup = DispatchGroup()
    
    var viewModel: UsersViewModel!
    var isSearching = false
    var selectedIndexPath: IndexPath?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        handleViewModelResult()
        self.viewModel.fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = selectedIndexPath {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func handleViewModelResult() {
        viewModel.changeResult = { type in
            switch type {
            case .loadUsers:
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func configureViews() {
        
        setUpReachability()
        navigationItem.titleView = searchBar
        view.addSubview(tableView)
        view.addSubview(noInternetView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.rowHeight = 90
        tableView.register(UserCell.self, forCellReuseIdentifier: String(describing: UserCell.self))
        
        noInternetView.translatesAutoresizingMaskIntoConstraints = false
        noInternetView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        noInternetView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        noInternetView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        noInternetView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setUpReachability()
    {
        DispatchQueue.main.async {

            self.reachability.whenReachable = { reachability in
                self.noInternetView.isHidden = true
                self.viewModel.fetchUsers(self.viewModel.failedFetch)
            }
            
            self.self.reachability.whenUnreachable = { _ in
                self.noInternetView.isHidden = false
            }

            do {
                try self.reachability.startNotifier()
            } catch {
                print("Unable to start notifier")
            }

        }
    }

}

extension UsersViewController: UITableViewDataSource, UITableViewDelegate, PagedTableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserCell.self), for: indexPath) as! UserCell
        let user = viewModel.users[indexPath.row]
        cell.userProtocol = self.viewModel
        cell.configure(user, indexPath, dispatchGroup)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.users[indexPath.row]
        selectedIndexPath = indexPath
        viewModel.coordinatorDelegate?.toProfileView(user: user)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))

            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = false
        }
    }
    
    func tableView(_ tableView: PagedTableView, needsDataForPage page: Int, completion: (Int, NSError?) -> Void) {
        viewModel.fetchUsers(false)
        completion(tableView.elementsPerPage, nil)
    }
}

extension UsersViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView === tableView {
      tableView.scrollViewDidScroll(tableView)
    }
  }
}

extension UsersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            isSearching = true
        } else {
            isSearching = false
        }
        
        viewModel.searchUser(by: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.resignFirstResponder()
        viewModel.fetchUsers()
    }
}
