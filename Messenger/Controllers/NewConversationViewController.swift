//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by 이지석 on 2021/09/10.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    private let searchBar : UISearchBar = {
        let sBar = UISearchBar()
        sBar.placeholder = "유저를 검색해주세요..."
        
        return sBar
    }()
    
    private let tableView : UITableView = {
       let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        
        return table
    }()
    
    private let noResultLabel : UILabel = {
       let lbl = UILabel()
        lbl.isHidden = true
        lbl.text = "결과 없음"
        lbl.textAlignment = .center
        lbl.textColor = .green
        lbl.font = .systemFont(ofSize: 21, weight: .medium)
        
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "취소",
                                                          style: .done,
                                                          target: self,
                                                          action: #selector(dismissSelf))
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}


extension NewConversationViewController : UISearchBarDelegate {
    // 키보드의 검색 버튼을 누를 때 호출
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
