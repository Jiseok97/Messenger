//
//  ViewController.swift
//  Messenger
//
//  Created by 이지석 on 2021/09/10.
//

import UIKit
import FirebaseAuth

class ConversationViewController: UIViewController {

    private let tableView: UITableView = {
       let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self,
                      forCellReuseIdentifier: "cell")
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }

    private func validateAuth() {
        // Auth.auth().currentUser → 현재 로그인한 사용자
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

