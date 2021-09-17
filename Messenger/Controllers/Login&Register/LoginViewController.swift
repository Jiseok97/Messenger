//
//  LoginViewController.swift
//  Messenger
//
//  Created by 이지석 on 2021/09/10.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let scrollView : UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        // clipsToBounds → ture일 때, 내용들과 서브뷰들은 뷰의 테두리를 기준으로 잘리게 된다.(defualt → false)
        return scrollView
    }()

    private let imageView : UIImageView = {
       let imgView = UIImageView()
        imgView.image = UIImage(named: "logo")
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private let emailField : UITextField = {
       let field = UITextField()
        field.autocapitalizationType = .none   // 자동 대문자 X
        field.autocorrectionType = .no   // 자동 수정 X
        field.returnKeyType = .continue   // 다음으로 넘어갈 수 있게 (PW TF)
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "이메일 입력..."
        
        field.clearButtonMode = .always
        field.clearButtonMode = .whileEditing
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField : UITextField = {
       let field = UITextField()
        field.autocapitalizationType = .none   // 자동 대문자 X
        field.autocorrectionType = .no   // 자동 수정 X
        field.returnKeyType = .continue   // 다음으로 넘어갈 수 있게 (Log in Btn)
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "비밀번호 입력..."
        
        field.clearButtonMode = .always
        field.clearButtonMode = .whileEditing
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        field.isSecureTextEntry = true
        
        return field
    }()
    
    private let loginBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("로그인", for: .normal)
        btn.backgroundColor = .link
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        return btn
    }()
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    func setUI() {
        title = "로그인"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "회원가입",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginBtn.addTarget(self, action: #selector(loginBtnTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginBtn)
    }
    
    // MARK: width & height .. etc Extensions 정의
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: (scrollView.width - size) / 2,
                                y: 60,
                                width: size,
                                height: size)
        
        emailField.frame = CGRect(x: 30,
                                 y: imageView.bottom + 30,
                                 width: scrollView.width - 60,
                                 height: 47)
        
        passwordField.frame = CGRect(x: 30,
                                    y: emailField.bottom + 10,
                                    width: scrollView.width - 60,
                                    height: 47)
        
        loginBtn.frame = CGRect(x: 30,
                               y: passwordField.bottom + 23,
                               width: scrollView.width - 60,
                               height: 47)
    }
    
    
    @objc private func loginBtnTapped() {
        // resignFirstResponder → 키보드 숨기기
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        // MARK: Firebase 로그인
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard let result = authResult, error == nil else {
                // 로그인 실패
                print("로그인 실패 \(email)")
                return
            }
            // 로그인 성공
            let user = result.user
            print("로그인 성공: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "로그인 실패",
                                     message: "이메일 혹은 비밀번호를 다시 확인해주세요",
                                     preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }

}


extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            // 이메일에서 비밀번호 TF로 포커스 될 수 있도록
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginBtnTapped()
        }
        
        return true
    }
}
