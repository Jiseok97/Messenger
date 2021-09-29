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
    
    private var users = [[String: String]]()
    private var results = [[String: String]]()
    // Firebase 결과 비어있는지 안비어있는지 체크 변수
    private var hasFetched = false
    
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
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 21, weight: .medium)
        
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "취소",
                                                          style: .done,
                                                          target: self,
                                                          action: #selector(dismissSelf))
        // 키보드를 호출하는 처 번째 응답자 → searchBar
        searchBar.becomeFirstResponder()
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.width / 4,
                                    y: (view.height - 200) / 2,
                                    width: view.width / 2,
                                    height: 100)
    }
}

extension NewConversationViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 채팅 시작
        
    }
}


extension NewConversationViewController : UISearchBarDelegate {
    // 키보드의 검색 버튼을 누를 때 호출
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 필터
        // replacingOccurrences → 유효성 때문에 공백을 그냥 없음으로 바꿔주는 역할
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        
        self.searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        // fireabse의 결과값(array)가 있는 경우
        if hasFetched {
            // true: filter 제공
            fileterUsers(with: query)
            
        }
        else {
            //false: fetch 후 filter 제공
            DatabaseManager.shared.getAllUsers(completion: {[weak self] result in
                switch result {
                case .success(let userCollection):
                    self?.hasFetched = true
                    self?.users = userCollection
                    self?.fileterUsers(with: query)
                
                case .failure(let error):
                    print("유저를 데이터베이스에 가져오는데 실패하였습니다. → \(error)")
                }
            })
            
        }
    }
    
    
    // MARK: 필터 기능
    func fileterUsers(with term: String) {
        // UI를 업데이트하여 결과를 표시하거나 결과 레이블을 표시하지 않음
        guard hasFetched else { return }
        
        self.spinner.dismiss()
        
        let results: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else { return false }
            
            return name.hasPrefix(term.lowercased())
        })
        
        self.results = results
        updateUI()
    }
    
    // MARK: 필터의 결과에 따른 UI 업데이트
    func updateUI() {
        if results.isEmpty {
            self.noResultLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noResultLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
